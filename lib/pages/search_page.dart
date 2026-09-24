import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../state/player_state.dart';
import '../theme/app_theme.dart';
import '../widgets/song_tile.dart';

/// 搜索页：热门搜索 + 结果列表。
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<String> _hot = [];
  List<Song> _results = [];
  String _keyword = '热歌';

  @override
  void initState() {
    super.initState();
    _loadHot();
    _search('');
  }

  Future<void> _loadHot() async {
    final hot = await context.read<AppState>().api.hotSearch();
    if (mounted) setState(() => _hot = hot);
  }

  Future<void> _search(String kw) async {
    final api = context.read<AppState>().api;
    final r = await api.search(kw);
    if (mounted) {
      setState(() {
        _keyword = kw.isEmpty ? '热歌' : kw;
        _results = r;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;

    return ListView(
      padding: const EdgeInsets.fromLTRB(34, 30, 34, 40),
      children: [
        _Header('热门搜索', p),
        if (_hot.isNotEmpty)
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (var i = 0; i < _hot.length; i++)
                InkWell(
                  onTap: () => _search(_hot[i]),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    decoration: BoxDecoration(color: p.card.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(24)),
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: '${i + 1}  ', style: TextStyle(color: p.accent, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic)),
                        TextSpan(text: _hot[i], style: TextStyle(color: p.text, fontSize: 17)),
                      ]),
                    ),
                  ),
                ),
            ],
          ),
        _Header('“$_keyword” 的搜索结果', p),
        if (_results.isEmpty)
          const Padding(padding: EdgeInsets.symmetric(vertical: 60), child: Center(child: CircularProgressIndicator()))
        else
          Container(
            decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(22), boxShadow: [
              BoxShadow(color: p.accent.withValues(alpha: 0.10), blurRadius: 30, offset: const Offset(0, 8)),
            ]),
            child: Column(
              children: [
                for (var i = 0; i < _results.length; i++)
                  SongTile(
                    song: _results[i],
                    index: i,
                    coverColor: gradientColor(i),
                    isCurrent: _isCurrent(_results[i]),
                    onTap: () => context.read<PlayerState>().play(_results[i], queue: _results),
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

class _Header extends StatelessWidget {
  final String title;
  final AppPalette p;
  const _Header(this.title, this.p);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
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
