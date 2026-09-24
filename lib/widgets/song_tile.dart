import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import 'cover_art.dart';

/// 歌曲列表行（榜单/歌单/歌手/专辑/搜索结果通用）。
class SongTile extends StatelessWidget {
  final Song song;
  final int index;
  final bool isCurrent;
  final Color coverColor;
  final VoidCallback onTap;

  const SongTile({
    super.key,
    required this.song,
    required this.index,
    required this.isCurrent,
    required this.coverColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isCurrent ? p.nowLine : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Text(
                (index + 1).toString().padLeft(2, '0'),
                style: TextStyle(
                  color: isCurrent ? p.accent : p.textSecondary,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w400,
                ),
              ),
            ),
            CoverArt(name: song.name, color: coverColor, size: 52, radius: 10, showRing: false),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          song.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isCurrent ? p.accent : p.text,
                          ),
                        ),
                      ),
                      if (song.sq)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            border: Border.all(color: p.accent, width: 1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text('SQ', style: TextStyle(fontSize: 10, color: p.accent, fontWeight: FontWeight.w800)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: p.textSecondary),
                  ),
                ],
              ),
            ),
            Text(song.durationText, style: TextStyle(fontSize: 14, color: p.textSecondary)),
          ],
        ),
      ),
    );
  }
}
