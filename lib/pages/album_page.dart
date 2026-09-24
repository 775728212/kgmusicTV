import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../state/player_state.dart';
import '../theme/app_theme.dart';
import '../widgets/cover_art.dart';
import '../widgets/song_tile.dart';

/// 专辑详情：hero 头图 + 曲目列表。
class AlbumPage extends StatefulWidget {
  final Album album;
  const AlbumPage({super.key, required this.album});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  List<Song> _tracks = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tracks = await context.read<AppState>().api.albumTracks(widget.album);
    if (mounted) setState(() => _tracks = tracks);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final c2 = Color.lerp(widget.album.coverColor, const Color(0xFF8F6FFF), 0.5)!;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: p.backgroundGradient),
              ),
            ),
          ),
          ListView(
            padding: const EdgeInsets.fromLTRB(34, 30, 34, 40),
            children: [
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [widget.album.coverColor, c2]),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CoverArt(name: widget.album.name, color: widget.album.coverColor, size: 180, radius: 24, showRing: false),
                    const SizedBox(width: 30),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.album.name, style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: Colors.white)),
                          const SizedBox(height: 12),
                          Text('${widget.album.artist} · ${widget.album.publishTime}年发行 · 共 ${widget.album.trackCount} 首',
                              style: const TextStyle(fontSize: 16, color: Colors.white70)),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26)),
                                child: const Text('▶ 播放全部', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFFFF5C8A))),
                              ),
                              const SizedBox(width: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(26)),
                                child: const Text('+ 收藏', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 30)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(22)),
                child: _tracks.isEmpty
                    ? const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
                    : Column(
                        children: [
                          for (var i = 0; i < _tracks.length; i++)
                            SongTile(
                              song: _tracks[i],
                              index: i,
                              coverColor: gradientColor(i),
                              isCurrent: _isCurrent(_tracks[i]),
                              onTap: () => context.read<PlayerState>().play(_tracks[i], queue: _tracks),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isCurrent(Song s) {
    final cur = context.read<PlayerState>().current;
    return cur != null && cur.name == s.name;
  }
}
