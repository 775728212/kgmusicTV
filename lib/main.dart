import 'package:flutter/material.dart';

import 'api/http_api.dart';
import 'api/kugou_api.dart';
import 'api/kugou_server.dart';
import 'api/mock_api.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = await createApi();
  runApp(KugouCarApp(api: api));
}

/// 决定用哪个 API 实现：
/// 1. 尝试启动内嵌 libkugou_server.so 本地服务器 → 成功则用 [HttpKugouApi]；
/// 2. 失败（桌面无 .so / 端口占用 / web）→ 回退 [MockKugouApi] 跑通 UI。
///
/// 当前开发机（无 Android 环境、无 kugou_server.dll）必然走 mock；
/// 真机装上 jniLibs 后自动切 http，页面层零改动。
Future<KugouApi> createApi() async {
  try {
    await KugouApiServer.start();
    if (KugouApiServer.currentPort > 0) {
      return HttpKugouApi();
    }
  } catch (_) {
    // 忽略启动失败，回退 mock
  }
  return MockKugouApi();
}
