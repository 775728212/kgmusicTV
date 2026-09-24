import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../state/player_state.dart';

/// 全屏歌词播放器：封面色模糊背景 + 左封面（旋转）+ 右歌词（当前行高亮）。
class FullPlayer extends StatefulWidget {
  const FullPlayer({super.key});

  @override
  State<FullPlayer> createState() => _FullPlayerState();
}

class _FullPlayerState extends State<FullPlayer> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final player = context.watch<PlayerState>();
    final song = player.current;

    final color = song == null ? const Color(0xFFFF7BA0) : gradientColor(song.name.hashCode.abs());
    final c2 = Color.lerp(color, const Color(0xFF8F6FFF), 0.5)!;

    return Container(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 封面色模糊背景
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color, c2]),
              ),
            ),
          ),
          // 暗化遮罩
          Positioned.fill(child: ColoredBox(color: Colors.black.withValues(alpha: 0.30))),
          // 内容
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 110),
              child: Row(
                children: [
                  // 左：旋转封面
                  _SpinningCover(name: song?.name ?? '♪', color: color),
                  const SizedBox(width: 90),
                  // 右：标题 + 歌词
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 70),
                        Text(song?.name ?? '未在播放', style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 12),
                        Text(song == null ? '' : '${song.artist} · 专辑《${song.album}》',
                            style: const TextStyle(fontSize: 20, color: Colors.white70)),
                        const SizedBox(height: 30),
                        Expanded(child: _LyricView(scroll: _scroll, player: player)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 顶部关闭
          Positioned(
            top: 34,
            right: 44,
            child: InkWell(
              onTap: app.closeFullPlayer,
              customBorder: const CircleBorder(),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle),
                child: const Icon(Icons.keyboard_arrow_down_rounded, size: 30, color: Colors.white),
              ),
            ),
          ),
          // 底部控制
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 210),
                  child: _FullProgress(player: player),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _WhiteCtrl(icon: Icons.repeat_rounded, size: 26, onTap: () {}),
                    const SizedBox(width: 34),
                    _WhiteCtrl(icon: Icons.skip_previous_rounded, size: 32, onTap: player.prev),
                    const SizedBox(width: 34),
                    _WhitePlay(playing: player.playing, onTap: player.toggle),
                    const SizedBox(width: 34),
                    _WhiteCtrl(icon: Icons.skip_next_rounded, size: 32, onTap: player.next),
                    const SizedBox(width: 34),
                    _WhiteCtrl(icon: Icons.favorite_border_rounded, size: 26, onTap: () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpinningCover extends StatefulWidget {
  final String name;
  final Color color;
  const _SpinningCover({required this.name, required this.color});

  @override
  State<_SpinningCover> createState() => _SpinningCoverState();
}

class _SpinningCoverState extends State<_SpinningCover> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 22))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c2 = Color.lerp(widget.color, Colors.white, 0.22)!;
    return SizedBox(
      width: 430,
      height: 430,
      child: RotationTransition(
        turns: _c,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [widget.color, c2]),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 90, offset: const Offset(0, 30))],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(widget.name.isEmpty ? '♪' : widget.name.characters.first,
                  style: const TextStyle(color: Colors.white, fontSize: 130, fontWeight: FontWeight.w900)),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), shape: BoxShape.circle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LyricView extends StatelessWidget {
  final ScrollController scroll;
  final PlayerState player;
  const _LyricView({required this.scroll, required this.player});

  @override
  Widget build(BuildContext context) {
    final lyrics = player.lyrics;
    final cur = player.currentLyricIndex;

    if (lyrics.isEmpty) {
      return const Center(child: Text('暂无歌词', style: TextStyle(color: Colors.white54, fontSize: 20)));
    }

    // 自动滚动到当前行（粗略估算行高）。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients && cur >= 0) {
        final target = (cur * 54.0).clamp(0.0, scroll.position.maxScrollExtent);
        scroll.animateTo(target, duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
      }
    });

    return ListView.builder(
      controller: scroll,
      padding: const EdgeInsets.symmetric(vertical: 150),
      itemCount: lyrics.length,
      itemBuilder: (context, i) {
        final isCur = i == cur;
        return Container(
          height: 54,
          alignment: Alignment.centerLeft,
          child: Text(
            lyrics[i].text,
            style: TextStyle(
              fontSize: isCur ? 31 : 26,
              fontWeight: isCur ? FontWeight.w800 : FontWeight.w400,
              color: isCur ? Colors.white : Colors.white.withValues(alpha: 0.45),
              shadows: isCur ? [const Shadow(color: Colors.black45, blurRadius: 16, offset: Offset(0, 4))] : null,
            ),
          ),
        );
      },
    );
  }
}

class _WhiteCtrl extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;
  const _WhiteCtrl({required this.icon, required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, customBorder: const CircleBorder(), child: Padding(padding: const EdgeInsets.all(8), child: Icon(icon, size: size, color: Colors.white)));
  }
}

class _WhitePlay extends StatelessWidget {
  final bool playing;
  final VoidCallback onTap;
  const _WhitePlay({required this.playing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 76,
        height: 76,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 38, color: const Color(0xFFFF5C8A)),
      ),
    );
  }
}

class _FullProgress extends StatelessWidget {
  final PlayerState player;
  const _FullProgress({required this.player});

  @override
  Widget build(BuildContext context) {
    final dur = player.duration;
    final pos = player.position;
    final totalMs = dur.inMilliseconds == 0 ? 1 : dur.inMilliseconds;
    final value = pos.inMilliseconds / totalMs;
    String fmt(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

    return Row(
      children: [
        Text(fmt(pos), style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(width: 14),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Text(fmt(dur), style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }
}
