import 'package:flutter/material.dart';

/// 歌曲
class Song {
  final String name;
  final String artist;
  final String album;
  final String hash; // 酷狗 fileHash，接真实 API 时作为唯一键
  final Duration duration;
  final String? coverUrl;
  final bool sq; // 无损标识

  const Song({
    required this.name,
    required this.artist,
    required this.album,
    this.hash = '',
    this.duration = const Duration(minutes: 4, seconds: 0),
    this.coverUrl,
    this.sq = true,
  });

  String get durationText {
    final m = duration.inMinutes;
    final s = duration.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

/// 歌单
class Playlist {
  final String id;
  final String name;
  final String desc;
  final String? coverUrl;
  final int playCount;
  final Color coverColor;

  const Playlist({
    required this.id,
    required this.name,
    required this.desc,
    this.coverUrl,
    this.playCount = 0,
    required this.coverColor,
  });
}

/// 排行榜分类
class RankCategory {
  final String name;
  final String desc;

  const RankCategory({required this.name, required this.desc});
}

/// 歌手
class Artist {
  final String id;
  final String name;
  final String? coverUrl;
  final int songCount;
  final int albumCount;
  final Color coverColor;

  const Artist({
    required this.id,
    required this.name,
    this.coverUrl,
    this.songCount = 0,
    this.albumCount = 0,
    required this.coverColor,
  });
}

/// 专辑
class Album {
  final String id;
  final String name;
  final String artist;
  final String? coverUrl;
  final String publishTime;
  final int trackCount;
  final Color coverColor;

  const Album({
    required this.id,
    required this.name,
    required this.artist,
    this.coverUrl,
    this.publishTime = '',
    this.trackCount = 0,
    required this.coverColor,
  });
}

/// 歌词行
class LyricLine {
  final Duration time;
  final String text;

  const LyricLine(this.time, this.text);
}

/// 封面渐变配色池（与 HTML 原型一致）。
const List<List<Color>> kCoverGradients = [
  [Color(0xFFFF7BA0), Color(0xFFFF5C8A)],
  [Color(0xFF8F6FFF), Color(0xFF6F8BFF)],
  [Color(0xFF5AA4FF), Color(0xFF3DD6C3)],
  [Color(0xFFFFB35C), Color(0xFFFF7A5C)],
  [Color(0xFF3DD6C3), Color(0xFF5AA4FF)],
  [Color(0xFFF97BA8), Color(0xFFC86FFF)],
  [Color(0xFF6FD3A8), Color(0xFF3DA9FC)],
  [Color(0xFFFF9A6C), Color(0xFFF95C8A)],
];

/// 按索引取稳定渐变主色。
Color gradientColor(int i) => kCoverGradients[i % kCoverGradients.length][0];
