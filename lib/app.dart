import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'api/kugou_api.dart';
import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/rank_page.dart';
import 'pages/playlist_page.dart';
import 'pages/fm_page.dart';
import 'pages/mine_page.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'widgets/bottom_player.dart';
import 'widgets/full_player.dart';
import 'widgets/sidebar.dart';
import 'widgets/top_bar.dart';

class KugouCarApp extends StatelessWidget {
  const KugouCarApp({super.key, required this.api});

  final KugouApi api;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(api: api),
      child: Consumer<AppState>(
        builder: (context, app, _) {
          return ListenableBuilder(
            listenable: app.theme,
            builder: (context, _) {
              final palette = app.theme.palette;
              return MaterialApp(
                title: '酷狗概念版 · 车机版',
                debugShowCheckedModeBanner: false,
                theme: buildTheme(palette),
                home: const MainShell(),
              );
            },
          );
        },
      ),
    );
  }
}

/// 主布局：左侧栏 + 主区（顶栏/页面/底部播放条）+ 全屏播放器覆盖层。
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      body: Stack(
        children: [
          // 渐变背景
          Positioned.fill(
            child: _GradientBackground(),
          ),
          Row(
            children: [
              const Sidebar(),
              Expanded(
                child: Column(
                  children: [
                    const TopBar(),
                    Expanded(child: _PageSwitcher(app: app)),
                    const BottomPlayer(),
                  ],
                ),
              ),
            ],
          ),
          // 全屏播放器覆盖
          if (app.fullPlayer) const FullPlayer(),
        ],
      ),
    );
  }
}

/// 页面渐变背景（粉白 → 淡紫 → 淡蓝 / 深色对应）。
class _GradientBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: p.backgroundGradient,
        ),
      ),
    );
  }
}

class _PageSwitcher extends StatelessWidget {
  final AppState app;
  const _PageSwitcher({required this.app});

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: app.nav.index,
      children: const [
        HomePage(),
        SearchPage(),
        RankPage(),
        PlaylistPage(),
        FmPage(),
        MinePage(),
      ],
    );
  }
}
