import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../state/player_state.dart';
import '../theme/app_theme.dart';
import '../widgets/cover_art.dart';
import '../widgets/song_tile.dart';

/// 歌单广场：分类 + 歌单网格 + 歌单详情。
class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  static const _cats = ['全部', '流行', '摇滚', '民谣', '电子', '说唱', '古风', '轻音乐', '粤语', '欧美', '日语', '韩语'];

  List<Playlist> _playlists = [];
  Playlist? _opened; // 点开的歌单
  List<Song> _tracks = [];
  int _cat = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = context.read<AppState>().api;
    final pl = await api.recommendPlaylists();
    // 用完整歌单列表填充（mock 里 recommendPlaylists 只返回 5 个，这里补全）
    if (mounted) setState(() => _playlists = pl);
  }

  Future<void> _open(Playlist pl) async {
    final api = context.read<AppState>().api;
    setState(() => _opened = pl);
    final tracks = await api.playlistTracks(pl);
    if (mounted) setState(() => _tracks = tracks);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(34, 30, 34, 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 260,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(22), boxShadow: [
              BoxShadow(color: p.accent.withValues(alpha: 0.10), blurRadius: 30, offset: const Offset(0, 8)),
            ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('分类', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: p.text)),
                const SizedBox(height: 12),
                for (var i = 0; i < _cats.length; i++)
                  InkWell(
                    onTap: () => setState(() => _cat = i),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: i == _cat ? p.accentSoft : null,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(_cats[i],
                          style: TextStyle(fontSize: 17, color: i == _cat ? p.accent : p.textSecondary,
                              fontWeight: i == _cat ? FontWeight.w800 : FontWeight.w400)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 26),
          // 右侧：网格或详情
          Expanded(
            child: _opened == null
                ? (_playlists.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.count(
                        crossAxisCount: 4,
                        mainAxisSpacing: 22,
                        crossAxisSpacing: 22,
                        childAspectRatio: 0.8,
                        children: [
                          for (var i = 0; i < _playlists.length; i++)
                            _PlCard(pl: _playlists[i], onTap: () => _open(_playlists[i])),
                        ],
                      ))
                : _PlaylistDetail(pl: _opened!, tracks: _tracks, onBack: () => setState(() => _opened = null)),
          ),
        ],
      ),
    );
  }
}

class _PlCard extends StatelessWidget {
  final Playlist pl;
  final VoidCallback onTap;
  const _PlCard({required this.pl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(20), boxShadow: [
          BoxShadow(color: p.accent.withValues(alpha: 0.10), blurRadius: 30, offset: const Offset(0, 8)),
        ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: CoverArt(name: pl.name, color: pl.coverColor, radius: 16)),
            const SizedBox(height: 12),
            Text(pl.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: p.text)),
            const SizedBox(height: 4),
            Text('▶ ${(pl.playCount / 100000).toStringAsFixed(0)}万 播放',
                maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: p.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _PlaylistDetail extends StatelessWidget {
  final Playlist pl;
  final List<Song> tracks;
  final VoidCallback onBack;
  const _PlaylistDetail({required this.pl, required this.tracks, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(22), boxShadow: [
        BoxShadow(color: p.accent.withValues(alpha: 0.10), blurRadius: 30, offset: const Offset(0, 8)),
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(onPressed: onBack, icon: Icon(Icons.arrow_back_rounded, color: p.text)),
              CoverArt(name: pl.name, color: pl.coverColor, size: 110, radius: 20),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pl.name, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: p.text)),
                  const SizedBox(height: 8),
                  Text('${pl.desc} · ${pl.playCount}人收藏', style: TextStyle(fontSize: 15, color: p.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          Expanded(
            child: tracks.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      for (var i = 0; i < tracks.length; i++)
                        SongTile(
                          song: tracks[i],
                          index: i,
                          coverColor: gradientColor(i),
                          isCurrent: _isCurrent(context, tracks[i]),
                          onTap: () => context.read<PlayerState>().play(tracks[i], queue: tracks),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  bool _isCurrent(BuildContext context, Song s) {
    final cur = context.read<PlayerState>().current;
    return cur != null && cur.name == s.name;
  }
}
