import 'dart:async';

import 'package:flutter/material.dart';

import '../api/kugou_api.dart';
import '../models/models.dart';

/// 播放状态：当前歌曲、队列、播放/暂停、进度、歌词。
/// 现在不接真实音频，仅维护 UI 状态；后续接 just_audio 时替换底层。
class PlayerState extends ChangeNotifier {
  PlayerState(this._api);

  final KugouApi _api;

  Song? _current;
  List<Song> _queue = [];
  int _index = -1;
  bool _playing = false;
  Duration _position = Duration.zero;
  List<LyricLine> _lyrics = [];

  Song? get current => _current;
  List<Song> get queue => _queue;
  bool get playing => _playing;
  Duration get position => _position;
  List<LyricLine> get lyrics => _lyrics;

  Duration get duration => _current?.duration ?? const Duration(minutes: 4);

  bool get hasSong => _current != null;

  void play(Song song, {List<Song>? queue}) {
    _queue = queue ?? [song];
    _index = _queue.indexWhere((s) => s.hash == song.hash && s.name == song.name);
    if (_index < 0) {
      _index = 0;
      _queue = [song];
    }
    _current = song;
    _playing = true;
    _position = Duration.zero;
    _loadLyrics(song);
    notifyListeners();
  }

  Future<void> _loadLyrics(Song song) async {
    try {
      _lyrics = await _api.lyric(song);
    } catch (_) {
      _lyrics = [LyricLine(Duration.zero, song.name)];
    }
    notifyListeners();
  }

  void toggle() {
    _playing = !_playing;
    notifyListeners();
  }

  void next() {
    if (_queue.isEmpty) return;
    _index = (_index + 1) % _queue.length;
    play(_queue[_index], queue: _queue);
  }

  void prev() {
    if (_queue.isEmpty) return;
    if (_position.inSeconds > 3) {
      _position = Duration.zero;
      notifyListeners();
      return;
    }
    _index = (_index - 1 + _queue.length) % _queue.length;
    play(_queue[_index], queue: _queue);
  }

  void seekTo(Duration d) {
    _position = d;
    notifyListeners();
  }

  /// 当前歌词行索引（根据播放进度）。
  int get currentLyricIndex {
    if (_lyrics.isEmpty) return -1;
    var idx = 0;
    for (var i = 0; i < _lyrics.length; i++) {
      if (_lyrics[i].time <= _position) idx = i;
    }
    return idx;
  }
}
