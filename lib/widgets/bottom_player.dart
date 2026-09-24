import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../state/player_state.dart';
import '../theme/app_theme.dart';
import 'cover_art.dart';

/// 底部悬浮圆角播放条（EchoMusic 风格：四周留白 + 大圆角）。
class BottomPlayer extends StatelessWidget {
  const BottomPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final player = context.watch<PlayerState>();
    final p = context.watch<ThemeController>().palette;

    final song = player.current;
    final color = song == null ? const Color(0xFFFF7BA0) : _colorFor(song);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: p.playerBar,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: p.line),
          boxShadow: [BoxShadow(color: p.accent.withValues(alpha: 0.10), blurRadius: 30, offset: const Offset(0, 8))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Row(
          children: [
            // 封面 + 歌名
            GestureDetector(
              onTap: app.openFullPlayer,
              child: Row(
                children: [
                  CoverArt(name: song?.name ?? '♪', color: color, size: 66, radius: 16, showRing: false),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 220,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(song?.name ?? '未在播放', maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: p.text)),
                        const SizedBox(height: 4),
                        Text(song == null ? '点击任意歌曲开始播放' : '${song.artist} · ${song.album}',
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, color: p.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // 中间控制
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CtrlBtn(icon: Icons.repeat_rounded, size: 24, color: p.textSecondary, onTap: () {}),
                    const SizedBox(width: 26),
                    _CtrlBtn(icon: Icons.skip_previous_rounded, size: 30, color: p.text, onTap: player.prev),
                    const SizedBox(width: 26),
                    _PlayBtn(playing: player.playing, color: color, onTap: player.toggle),
                    const SizedBox(width: 26),
                    _CtrlBtn(icon: Icons.skip_next_rounded, size: 30, color: p.text, onTap: player.next),
                    const SizedBox(width: 26),
                    _CtrlBtn(icon: Icons.lyrics_rounded, size: 24, color: p.textSecondary, onTap: app.openFullPlayer),
                  ],
                ),
                const SizedBox(height: 4),
                _ProgressBar(player: player, p: p),
              ],
            ),
            const Spacer(),
            // 右侧
            Row(
              children: [
                Text('SQ', style: TextStyle(fontSize: 12, color: p.accent, fontWeight: FontWeight.w800)),
                const SizedBox(width: 20),
                _CtrlBtn(icon: Icons.equalizer_rounded, size: 24, color: p.textSecondary, onTap: () {}),
                const SizedBox(width: 20),
                _CtrlBtn(icon: Icons.queue_music_rounded, size: 24, color: p.textSecondary, onTap: () {}),
                const SizedBox(width: 16),
                Icon(Icons.volume_up_rounded, size: 22, color: p.textSecondary),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: 0.7,
                      minHeight: 5,
                      backgroundColor: p.line,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _colorFor(Song song) => gradientColor(song.name.hashCode.abs());
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback onTap;
  const _CtrlBtn({required this.icon, required this.size, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(padding: const EdgeInsets.all(6), child: Icon(icon, size: size, color: color)),
    );
  }
}

class _PlayBtn extends StatelessWidget {
  final bool playing;
  final Color color;
  final VoidCallback onTap;
  const _PlayBtn({required this.playing, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, Color.lerp(color, Colors.white, 0.25)!], begin: Alignment.topLeft, end: Alignment.bottomRight),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 30, color: Colors.white),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final PlayerState player;
  final AppPalette p;
  const _ProgressBar({required this.player, required this.p});

  @override
  Widget build(BuildContext context) {
    final dur = player.duration;
    final pos = player.position;
    final totalMs = dur.inMilliseconds == 0 ? 1 : dur.inMilliseconds;
    final value = pos.inMilliseconds / totalMs;

    String fmt(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

    return SizedBox(
      width: 560,
      child: Row(
        children: [
          Text(fmt(pos), style: TextStyle(fontSize: 12, color: p.textSecondary)),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                minHeight: 5,
                backgroundColor: p.line,
                valueColor: AlwaysStoppedAnimation(p.accent),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(fmt(dur), style: TextStyle(fontSize: 12, color: p.textSecondary)),
        ],
      ),
    );
  }
}
