import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'kugou_endpoints.dart';

/// libkugou_server.so 的 FFI 类型声明。
/// 纯 C 符号（不含包名，JNI 符号不匹配时也能用）：
///   int  start_server(int port, const char* data_dir)  // port==0 随机选端口
///   void stop_server()
///   int  is_server_running()                            // 1=运行中
///   int  get_server_port()
typedef _StartServerNative = Int32 Function(Int32 port, Pointer<Utf8> dataDir);
typedef _StartServer = int Function(int port, Pointer<Utf8> dataDir);
typedef _StopServerNative = Void Function();
typedef _StopServer = void Function();
typedef _IsRunningNative = Int32 Function();
typedef _IsRunning = int Function();

/// 内嵌 API 服务器启动器。
///
/// 通过 dart:ffi 直接调用 libkugou_server.so 的纯 C 函数启动/停止 127.0.0.1
/// 上的随机端口 HTTP 服务器，并把实际端口写回 [KugouEndpoints.baseUrl]。
///
/// 设计要点（对齐 MD3Music 的 kugou_server.dart）：
/// - 优先走 dart:ffi（纯 C 符号不含包名，不受 .so 编译包名影响）；
/// - 启动前先探测是否已运行，避免重复 dlopen + start_server；
/// - 启动失败时重置去重 Future，允许后续重试。
class KugouApiServer {
  static bool _started = false;
  static Future<void>? _startFuture;
  static DynamicLibrary? _lib;
  static _StopServer? _stopFn;
  static _IsRunning? _isRunningFn;

  /// 启动本地服务器（幂等，并发安全）。kIsWeb 时跳过。
  static Future<void> start() async {
    if (_started || kIsWeb) return;
    return _startFuture ??= _doStart();
  }

  static Future<void> _doStart() async {
    try {
      final lib = _loadLib();
      final startServer =
          lib.lookupFunction<_StartServerNative, _StartServer>('start_server');
      _stopFn ??=
          lib.lookupFunction<_StopServerNative, _StopServer>('stop_server');
      _isRunningFn ??=
          lib.lookupFunction<_IsRunningNative, _IsRunning>('is_server_running');

      // 已在运行则直接拿端口，不重复启动。
      if (_isRunningFn!() == 1) {
        final p = _getPort(lib);
        if (p > 0) {
          _applyPort(p);
          _started = true;
          await _waitReady(p);
          return;
        }
      }

      // 用 path_provider 拿 filesDir 作为 data_dir（持久化 device_info.json）。
      // 真机 release 下 path_provider 底层走 JNI，可能挂起；加超时 + 临时目录兜底。
      Directory appDir;
      try {
        appDir = await getApplicationSupportDirectory()
            .timeout(const Duration(seconds: 3));
      } catch (_) {
        appDir = Directory.systemTemp;
      }
      final dataDir = appDir.path.toNativeUtf8();
      late int port;
      try {
        port = startServer(0, dataDir); // 0 = 随机端口
      } finally {
        malloc.free(dataDir);
      }

      if (port <= 0) {
        throw StateError('start_server failed with code $port');
      }
      _applyPort(port);
      _started = true;
      await _waitReady(port);
    } catch (e) {
      debugPrint('KugouApiServer start failed: $e');
      // 重置去重 Future，允许后续（如播放前兜底）重试。
      _startFuture = null;
    }
  }

  static int _getPort(DynamicLibrary lib) {
    try {
      final getPort =
          lib.lookupFunction<_IsRunningNative, _IsRunning>('get_server_port');
      return getPort();
    } catch (_) {
      return 0;
    }
  }

  static DynamicLibrary _loadLib() {
    return _lib ??= DynamicLibrary.open('libkugou_server.so');
  }

  static void _applyPort(int port) {
    KugouEndpoints.baseUrl = 'http://127.0.0.1:$port';
    debugPrint('Kugou API server ready on ${KugouEndpoints.baseUrl}');
  }

  /// 当前端口（未启动/失败时为 0）。
  static int get currentPort {
    final uri = Uri.tryParse(KugouEndpoints.baseUrl);
    return uri?.port ?? 0;
  }

  /// TCP 探测就绪，最多等 6 秒（start_server 返回端口即已 bind，通常 <100ms）。
  static Future<void> _waitReady(int port) async {
    for (var i = 0; i < 30; i++) {
      try {
        final socket = await Socket.connect(
          '127.0.0.1',
          port,
          timeout: const Duration(milliseconds: 200),
        );
        await socket.close();
        return;
      } catch (_) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
    debugPrint('Kugou API server did not become ready within 6s');
  }

  static Future<bool> isRunning() async {
    try {
      final lib = _loadLib();
      _isRunningFn ??=
          lib.lookupFunction<_IsRunningNative, _IsRunning>('is_server_running');
      return _isRunningFn!() == 1;
    } catch (_) {
      return false;
    }
  }

  /// 停止服务器，释放端口（温和退出时确定性关停）。
  static Future<void> stop() async {
    if (kIsWeb) return;
    try {
      final lib = _loadLib();
      _stopFn ??=
          lib.lookupFunction<_StopServerNative, _StopServer>('stop_server');
      _stopFn!();
    } catch (e) {
      debugPrint('KugouApiServer stop error: $e');
    }
  }
}
