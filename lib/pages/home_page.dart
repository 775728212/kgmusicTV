import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../state/player_state.dart';
import '../theme/app_theme.dart';
import '../widgets/cover_art.dart';

/// 首页：问候语 + 每日推荐/排行榜大卡 + 推荐歌单 + 新歌速递。
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Playlist> _playlists = [];
  List<Song> _newSongs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = context.read<AppState>().api;
    final pl = await api.recommendPlaylists();
    final songs = await api.dailyRecommend();
    if (!mounted) return;
    setState(() {
      _playlists = pl;
      _newSongs = songs;
    });
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 6) return '夜深了 🌙';
    if (h < 12) return '上午好 ☀️';
    if (h < 18) return '下午好 🌞';
    return '晚上好 🌆';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final now = DateTime.now();

    return ListView(
      padding: const EdgeInsets.fromLTRB(34, 30, 34, 40),
      children: [
        Text(_greeting, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: p.text)),
        const SizedBox(height: 8),
        Text('欢迎回来，今天想听点什么？', style: TextStyle(fontSize: 18, color: p.textSecondary)),
        const SizedBox(height: 28),
        Row(
          children: [
            _HeroCard(
              title: '每日推荐',
              badge: '${now.day}',
              badgeSub: '${now.month}月',
              sub: '根据你的口味生成 · 每天 6:00 更新',
              colors: const [Color(0xFFFF7BA0), Color(0xFFFF5C8A), Color(0xFFFF8FB0)],
              onTap: () {},
            ),
            const SizedBox(width: 24),
            _HeroCard(
              title: '排行榜',
              badge: 'TOP',
              sub: '热歌榜 · 飙升榜 · 酷狗TOP500…',
              colors: const [Color(0xFF8F6FFF), Color(0xFF6F8BFF), Color(0xFF5AA4FF)],
              onTap: () => context.read<AppState>().go(NavPage.rank),
            ),
          ],
        ),
        _SectionHeader('推荐歌单', p),
        if (_playlists.isEmpty)
          const _LoadingGrid()
        else
          _CardGrid(
            children: [
              for (var i = 0; i < _playlists.length; i++)
                _SongCard(
                  title: _playlists[i].name,
                  subtitle: '▶ ${(_playlists[i].playCount / 100000).toStringAsFixed(0)}万 播放',
                  color: _playlists[i].coverColor,
                  onTap: () => context.read<AppState>().go(NavPage.playlist),
                ),
            ],
          ),
        _SectionHeader('为你推荐 · 新歌速递', p),
        if (_newSongs.isEmpty)
          const _LoadingGrid()
        else
          _CardGrid(
            children: [
              for (var i = 0; i < _newSongs.length; i++)
                _SongCard(
                  title: _newSongs[i].name,
                  subtitle: _newSongs[i].artist,
                  color: gradientColor(i),
                  onTap: () => context.read<PlayerState>().play(_newSongs[i], queue: _newSongs),
                ),
            ],
          ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final String badge;
  final String badgeSub;
  final String sub;
  final List<Color> colors;
  final VoidCallback onTap;
  const _HeroCard({
    required this.title,
    required this.badge,
    this.badgeSub = '',
    required this.sub,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(26),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                right: -30,
                bottom: -40,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.14), width: 26),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(width: 14),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: badgeSub.isEmpty ? 18 : 0, vertical: badgeSub.isEmpty ? 8 : 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(badgeSub.isEmpty ? 20 : 18),
                        ),
                        child: badgeSub.isEmpty
                            ? Text(badge, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 2))
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(badge, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, height: 1)),
                                  Text(badgeSub, style: const TextStyle(fontSize: 12, color: Colors.white)),
                                ],
                              ),
                      ),
                    ],
                  ),
                  Text(sub, style: const TextStyle(fontSize: 17, color: Colors.white70)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final AppPalette p;
  const _SectionHeader(this.title, this.p);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 18),
      child: Row(
        children: [
          Container(width: 6, height: 26, decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(colors: [p.accent, p.purple]),
          )),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: p.text)),
        ],
      ),
    );
  }
}

class _CardGrid extends StatelessWidget {
  final List<Widget> children;
  const _CardGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 22,
      crossAxisSpacing: 22,
      childAspectRatio: 0.82,
      children: children,
    );
  }
}

class _SongCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _SongCard({required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: p.accent.withValues(alpha: 0.10), blurRadius: 30, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: CoverArt(name: title, color: color, size: double.infinity, radius: 16)),
            const SizedBox(height: 12),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: p.text)),
            const SizedBox(height: 4),
            Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: p.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
