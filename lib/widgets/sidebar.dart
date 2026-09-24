import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// 左侧栏：用户卡 → 发现音乐 → 我的乐库 → 我的歌单 → 主题切换。
class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final p = context.watch<ThemeController>().palette;

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: p.card.withValues(alpha: p.isDark ? 0.82 : 0.72),
        border: Border(right: BorderSide(color: p.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          _UserCard(app: app, p: p),
          _SectionTitle('发现音乐', p),
          _NavItem(icon: Icons.home_rounded, label: '首页推荐', page: NavPage.home, app: app, p: p),
          _NavItem(icon: Icons.search_rounded, label: '搜索', page: NavPage.search, app: app, p: p),
          _NavItem(icon: Icons.leaderboard_rounded, label: '排行榜', page: NavPage.rank, app: app, p: p),
          _NavItem(icon: Icons.grid_view_rounded, label: '歌单广场', page: NavPage.playlist, app: app, p: p),
          _NavItem(icon: Icons.radio_rounded, label: '私人FM', page: NavPage.fm, app: app, p: p),
          _SectionTitle('我的乐库', p),
          _NavItem(icon: Icons.favorite_rounded, label: '我最喜爱', page: NavPage.mine, app: app, p: p),
          _NavItem(icon: Icons.history_rounded, label: '最近播放', page: NavPage.mine, app: app, p: p),
          const SizedBox(height: 8),
          Expanded(child: _PlaylistsSection(app: app, p: p)),
          _ThemeToggle(p: p),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AppState app;
  final AppPalette p;
  const _UserCard({required this.app, required this.p});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => app.go(NavPage.mine),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: p.accent.withValues(alpha: 0.10), blurRadius: 30, offset: const Offset(0, 8)),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: p.accent,
                child: Text('🐶', style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app.userName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: p.text)),
                    const SizedBox(height: 3),
                    Text(app.loggedIn ? 'ID: 10086 · 已登录' : '点击登录酷狗账号',
                        style: TextStyle(fontSize: 14, color: p.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final AppPalette p;
  const _SectionTitle(this.text, this.p);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 16, 6),
      child: Text(text, style: TextStyle(fontSize: 13, color: p.textSecondary, letterSpacing: 2)),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final NavPage page;
  final AppState app;
  final AppPalette p;
  const _NavItem({required this.icon, required this.label, required this.page, required this.app, required this.p});

  @override
  Widget build(BuildContext context) {
    final on = app.nav == page;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: InkWell(
        onTap: () => app.go(page),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: on ? p.accentSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, size: 24, color: on ? p.accent : p.textSecondary),
              const SizedBox(width: 14),
              Text(label,
                  style: TextStyle(fontSize: 18, fontWeight: on ? FontWeight.w700 : FontWeight.w400, color: on ? p.accent : p.text)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaylistsSection extends StatelessWidget {
  final AppState app;
  final AppPalette p;
  const _PlaylistsSection({required this.app, required this.p});

  @override
  Widget build(BuildContext context) {
    final pls = ['华语经典必听', '车载电音狂欢', '深夜情歌电台', '国语流行新歌速递', '经典粤语怀旧', '轻音乐·减压专享'];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          for (var i = 0; i < pls.length; i++)
            InkWell(
              onTap: () => app.go(NavPage.playlist),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: kCoverGradients[i % kCoverGradients.length],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(pls[i].substring(0, 1),
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(pls[i], maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16, color: p.textSecondary)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  final AppPalette p;
  const _ThemeToggle({required this.p});

  @override
  Widget build(BuildContext context) {
    final dark = p.isDark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Column(
        children: [
          Divider(color: p.line, height: 1),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => context.read<ThemeController>().toggle(),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, size: 22, color: p.textSecondary),
                  const SizedBox(width: 10),
                  Text(dark ? '白天模式' : '夜晚模式', style: TextStyle(fontSize: 16, color: p.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
