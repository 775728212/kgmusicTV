import 'package:flutter/material.dart';

import '../api/kugou_api.dart';
import '../api/mock_api.dart';
import '../theme/app_theme.dart';
import 'player_state.dart';

/// 应用侧栏页面（导航）。
enum NavPage { home, search, rank, playlist, fm, mine }

/// 全局应用状态：主题、登录态、当前导航、API、播放器。
class AppState extends ChangeNotifier {
  AppState({KugouApi? api})
      : theme = ThemeController(AppPalette.light),
        api = api ?? MockKugouApi();

  final ThemeController theme;
  final KugouApi api;
  late final PlayerState player = PlayerState(api);

  NavPage _nav = NavPage.home;
  bool _loggedIn = false;
  String _userName = '未登录';
  bool _fullPlayer = false;

  NavPage get nav => _nav;
  bool get loggedIn => _loggedIn;
  String get userName => _userName;
  bool get fullPlayer => _fullPlayer;

  void go(NavPage page) {
    if (_nav == page) return;
    _nav = page;
    notifyListeners();
  }

  void openFullPlayer() {
    _fullPlayer = true;
    notifyListeners();
  }

  void closeFullPlayer() {
    _fullPlayer = false;
    notifyListeners();
  }

  Future<bool> login(String phone, String code) async {
    final ok = await api.loginPhone(phone, code);
    if (ok) {
      _loggedIn = true;
      _userName = '车机用户_${phone.substring(7)}';
      notifyListeners();
    }
    return ok;
  }

  void logout() {
    _loggedIn = false;
    _userName = '未登录';
    notifyListeners();
  }
}
