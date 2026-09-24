import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../state/player_state.dart';
import '../theme/app_theme.dart';
import '../widgets/cover_art.dart';
import '../widgets/song_tile.dart';
import 'album_page.dart';

/// 歌手详情：hero 头图 + 热门歌曲/专辑 Tab。
class ArtistPage extends StatefulWidget {
  final Artist artist;
  const ArtistPage({super.key, required this.artist});

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  List<Song> _songs = [];
  List<Album> _albums = [];
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = context.read<AppState>().api;
    final songs = await api.artistSongs(widget.artist);
    final albums = await api.artistAlbums(widget.artist);
    if (mounted) {
      setState(() {
        _songs = songs;
        _albums = albums;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;

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
              // hero
              _Hero(
                name: widget.artist.name,
                meta: '单曲 ${widget.artist.songCount} · 专辑 ${widget.artist.albumCount} · 粉丝 2100万',
                color: widget.artist.coverColor,
                onBack: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),
              // tabs
              Row(
                children: [
                  _Tab('热门歌曲', 0, _tab, () => setState(() => _tab = 0), p),
                  const SizedBox(width: 26),
                  _Tab('专辑', 1, _tab, () => setState(() => _tab = 1), p),
                ],
              ),
              const SizedBox(height: 6),
              if (_tab == 0)
                _songs.isEmpty
                    ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                    : Container(
                        decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(22)),
                        child: Column(
                          children: [
                            for (var i = 0; i < _songs.length; i++)
                              SongTile(
                                song: _songs[i],
                                index: i,
                                coverColor: gradientColor(i),
                                isCurrent: _isCurrent(_songs[i]),
                                onTap: () => context.read<PlayerState>().play(_songs[i], queue: _songs),
                              ),
                          ],
                        ),
                      )
              else
                GridView.count(
                  crossAxisCount: 5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 22,
                  crossAxisSpacing: 22,
                  childAspectRatio: 0.82,
                  children: [
                    for (final a in _albums)
                      InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AlbumPage(album: a))),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: CoverArt(name: a.name, color: a.coverColor, radius: 16)),
                              const SizedBox(height: 12),
                              Text(a.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: p.text)),
                              const SizedBox(height: 4),
                              Text('${a.publishTime}年 · ${a.trackCount}首',
                                  style: TextStyle(fontSize: 14, color: p.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                  ],
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

class _Hero extends StatelessWidget {
  final String name;
  final String meta;
  final Color color;
  final VoidCallback onBack;
  const _Hero({required this.name, required this.meta, required this.color, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final c2 = Color.lerp(color, const Color(0xFF8F6FFF), 0.5)!;
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color, c2]),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CoverArt(name: name, color: color, size: 180, radius: 24, showRing: false),
          const SizedBox(width: 30),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name, style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 12),
                Text(meta, style: const TextStyle(fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 20),
                Row(
                  children: const [
                    _Pill('▶ 播放热门', solid: true),
                    SizedBox(width: 14),
                    _Pill('+ 关注'),
                  ],
                ),
              ],
            ),
          ),
          IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 30)),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final bool solid;
  const _Pill(this.text, {this.solid = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
      decoration: BoxDecoration(
        color: solid ? Colors.white : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Text(text, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: solid ? const Color(0xFFFF5C8A) : Colors.white)),
    );
  }
}

class _Tab extends StatelessWidget {
  final String text;
  final int index;
  final int selected;
  final VoidCallback onTap;
  final AppPalette p;
  const _Tab(this.text, this.index, this.selected, this.onTap, this.p);

  @override
  Widget build(BuildContext context) {
    final on = index == selected;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: on ? p.accent : Colors.transparent, width: 3))),
        child: Text(text, style: TextStyle(fontSize: 20, fontWeight: on ? FontWeight.w800 : FontWeight.w400, color: on ? p.accent : p.textSecondary)),
      ),
    );
  }
}
