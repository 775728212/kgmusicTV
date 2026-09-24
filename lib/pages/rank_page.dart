import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../state/player_state.dart';
import '../theme/app_theme.dart';
import '../widgets/cover_art.dart';
import '../widgets/song_tile.dart';

/// 排行榜：左侧分类 + 右侧榜单详情。
class RankPage extends StatefulWidget {
  const RankPage({super.key});

  @override
  State<RankPage> createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> {
  List<RankCategory> _categories = [];
  List<Song> _songs = [];
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = context.read<AppState>().api;
    final cats = await api.rankCategories();
    if (!mounted) return;
    setState(() => _categories = cats);
    await _select(0);
  }

  Future<void> _select(int i) async {
    final api = context.read<AppState>().api;
    setState(() => _selected = i);
    final songs = await api.rankSongs(_categories[i]);
    if (mounted) setState(() => _songs = songs);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final color = gradientColor(_selected);

    return Padding(
      padding: const EdgeInsets.fromLTRB(34, 30, 34, 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧分类
          Container(
            width: 300,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(22), boxShadow: [
              BoxShadow(color: p.accent.withValues(alpha: 0.10), blurRadius: 30, offset: const Offset(0, 8)),
            ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('官方榜', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: p.text)),
                const SizedBox(height: 12),
                for (var i = 0; i < _categories.length; i++)
                  InkWell(
                    onTap: () => _select(i),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: i == _selected ? p.accentSoft : null,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_categories[i].name,
                              style: TextStyle(fontSize: 18, color: i == _selected ? p.accent : p.textSecondary,
                                  fontWeight: i == _selected ? FontWeight.w800 : FontWeight.w400)),
                          Icon(Icons.chevron_right_rounded, color: p.textSecondary),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 26),
          // 右侧详情
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(22), boxShadow: [
                BoxShadow(color: p.accent.withValues(alpha: 0.10), blurRadius: 30, offset: const Offset(0, 8)),
              ]),
              child: _categories.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CoverArt(name: _categories[_selected].name, color: color, size: 120, radius: 20),
                            const SizedBox(width: 22),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_categories[_selected].name, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: p.text)),
                                const SizedBox(height: 8),
                                Text(_categories[_selected].desc, style: TextStyle(fontSize: 15, color: p.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Divider(height: 1),
                        Expanded(
                          child: ListView(
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
                        ),
                      ],
                    ),
            ),
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
