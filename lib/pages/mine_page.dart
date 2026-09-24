import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../state/player_state.dart';
import '../theme/app_theme.dart';
import '../widgets/song_tile.dart';
import '../widgets/top_bar.dart';

/// 我的：用户卡 + 统计 + 我最喜爱。
class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  List<Song> _fav = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final fav = await context.read<AppState>().api.favoriteSongs();
    if (mounted) setState(() => _fav = fav);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final p = context.watch<ThemeController>().palette;

    return ListView(
      padding: const EdgeInsets.fromLTRB(34, 30, 34, 40),
      children: [
        // 用户卡
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(24), boxShadow: [
            BoxShadow(color: p.accent.withValues(alpha: 0.10), blurRadius: 30, offset: const Offset(0, 8)),
          ]),
          child: Row(
            children: [
              CircleAvatar(radius: 44, backgroundColor: p.accent, child: Text('🐶', style: const TextStyle(fontSize: 40))),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app.userName, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: p.text)),
                    const SizedBox(height: 8),
                    Text(app.loggedIn ? '登录后同步收藏歌单、最近播放与云盘音乐' : '登录后同步收藏歌单、最近播放与云盘音乐（/user/detail）',
                        style: TextStyle(fontSize: 16, color: p.textSecondary)),
                  ],
                ),
              ),
              if (!app.loggedIn)
                FilledButton(
                  onPressed: () => showDialog(context: context, builder: (_) => const LoginDialog()),
                  style: FilledButton.styleFrom(
                    backgroundColor: p.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  ),
                  child: const Text('立即登录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        // 统计
        Row(
          children: [
            _StatCard(value: _fav.length, label: '喜欢的音乐', p: p),
            const SizedBox(width: 22),
            const _StatCard(value: 8, label: '收藏歌单', p: null),
            const SizedBox(width: 22),
            const _StatCard(value: 36, label: '最近播放', p: null),
            const SizedBox(width: 22),
            const _StatCard(value: 8, label: '收藏专辑', p: null),
          ],
        ),
        _Header('我最喜爱', p),
        if (_fav.isEmpty)
          const Padding(padding: EdgeInsets.symmetric(vertical: 60), child: Center(child: CircularProgressIndicator()))
        else
          Container(
            decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(22), boxShadow: [
              BoxShadow(color: p.accent.withValues(alpha: 0.10), blurRadius: 30, offset: const Offset(0, 8)),
            ]),
            child: Column(
              children: [
                for (var i = 0; i < _fav.length; i++)
                  SongTile(
                    song: _fav[i],
                    index: i,
                    coverColor: gradientColor(i),
                    isCurrent: _isCurrent(_fav[i]),
                    onTap: () => context.read<PlayerState>().play(_fav[i], queue: _fav),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  bool _isCurrent(Song s) {
    final cur = context.read<PlayerState>().current;
    return cur != null && cur.name == s.name;
  }
}

class _StatCard extends StatelessWidget {
  final int value;
  final String label;
  final AppPalette? p;
  const _StatCard({required this.value, required this.label, this.p});

  @override
  Widget build(BuildContext context) {
    final palette = p ?? context.watch<ThemeController>().palette;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(color: palette.card, borderRadius: BorderRadius.circular(20), boxShadow: [
          BoxShadow(color: palette.accent.withValues(alpha: 0.10), blurRadius: 30, offset: const Offset(0, 8)),
        ]),
        child: Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(colors: [palette.accent, palette.purple]).createShader(bounds),
              child: Text('$value', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 16, color: palette.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final AppPalette p;
  const _Header(this.title, this.p);

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
