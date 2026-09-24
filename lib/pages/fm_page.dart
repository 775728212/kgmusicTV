import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../state/player_state.dart';
import '../theme/app_theme.dart';
import '../widgets/cover_art.dart';

/// 私人FM：电台大卡 + 更多电台 + 场景电台。
class FmPage extends StatefulWidget {
  const FmPage({super.key});

  @override
  State<FmPage> createState() => _FmPageState();
}

class _FmPageState extends State<FmPage> {
  Song? _current;
  List<Playlist> _scenes = [];
  static const _radios = ['热歌电台', '新歌电台', '情景电台', '经典电台'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = context.read<AppState>().api;
    final song = await api.fmNext();
    final scenes = await api.fmScenes();
    if (mounted) {
      setState(() {
        _current = song;
        _scenes = scenes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;

    return ListView(
      padding: const EdgeInsets.fromLTRB(34, 30, 34, 40),
      children: [
        _FmHero(song: _current, onNext: _load),
        _Header('更多电台', p),
        Row(
          children: [
            for (var i = 0; i < _radios.length; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == _radios.length - 1 ? 0 : 22),
                  child: _RadioCard(name: _radios[i], color: gradientColor(i), song: _current),
                ),
              ),
          ],
        ),
        _Header('场景电台', p),
        if (_scenes.isEmpty)
          const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator()))
        else
          GridView.count(
            crossAxisCount: 6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 22,
            crossAxisSpacing: 22,
            childAspectRatio: 0.8,
            children: [
              for (var i = 0; i < _scenes.length; i++)
                _SceneCard(pl: _scenes[i]),
            ],
          ),
      ],
    );
  }
}

class _FmHero extends StatelessWidget {
  final Song? song;
  final VoidCallback onNext;
  const _FmHero({required this.song, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final color = song == null ? const Color(0xFFA06CFF) : gradientColor(song!.name.hashCode.abs());

    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2B2140), Color(0xFF41306B), Color(0xFF5C3D8F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          _SpinningCover(name: song?.name ?? '♪', color: color),
          const SizedBox(width: 34),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('私人FM · 专属电台', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 12),
                Text(song == null ? '加载中…' : '正在播放：${song!.name} · ${song!.artist}',
                    style: const TextStyle(fontSize: 17, color: Colors.white70)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _FmBtn(icon: Icons.skip_previous_rounded, onTap: onNext),
                    const SizedBox(width: 18),
                    _FmBtn(icon: Icons.play_arrow_rounded, size: 74, main: true, onTap: () => context.read<PlayerState>().toggle()),
                    const SizedBox(width: 18),
                    _FmBtn(icon: Icons.skip_next_rounded, onTap: onNext),
                    const SizedBox(width: 18),
                    _FmBtn(icon: Icons.favorite_border_rounded, onTap: () {}),
                  ],
                ),
                const SizedBox(height: 16),
                const _Spectrum(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FmBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool main;
  final VoidCallback onTap;
  const _FmBtn({required this.icon, this.size = 56, this.main = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: main ? Colors.white : Colors.white.withValues(alpha: 0.18),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: size * 0.5, color: main ? const Color(0xFFFF5C8A) : Colors.white),
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
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c2 = Color.lerp(widget.color, Colors.white, 0.22)!;
    return SizedBox(
      width: 220,
      height: 220,
      child: RotationTransition(
        turns: _c,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [widget.color, c2]),
            shape: BoxShape.circle,
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 50, offset: Offset(0, 20))],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(widget.name.isEmpty ? '♪' : widget.name.characters.first,
                  style: const TextStyle(color: Colors.white, fontSize: 70, fontWeight: FontWeight.w900)),
              Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), shape: BoxShape.circle)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Spectrum extends StatefulWidget {
  const _Spectrum();

  @override
  State<_Spectrum> createState() => _SpectrumState();
}

class _SpectrumState extends State<_Spectrum> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return SizedBox(
          height: 48,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < 26; i++)
                Container(
                  width: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 8 + 40 * (0.5 + 0.5 * sin(_c.value * 2 * pi + i * 0.6)),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFF5C8A), Color(0xFFFFD0E0)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RadioCard extends StatelessWidget {
  final String name;
  final Color color;
  final Song? song;
  const _RadioCard({required this.name, required this.color, this.song});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(20), boxShadow: [
        BoxShadow(color: p.accent.withValues(alpha: 0.10), blurRadius: 30, offset: const Offset(0, 8)),
      ]),
      child: Column(
        children: [
          CoverArt(name: name, color: color, size: 110, radius: 55, showRing: false),
          const SizedBox(height: 14),
          Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: p.text)),
          const SizedBox(height: 6),
          Text(song == null ? '正在播放' : '正在播放 · ${song!.name}',
              maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: p.textSecondary)),
        ],
      ),
    );
  }
}

class _SceneCard extends StatelessWidget {
  final Playlist pl;
  const _SceneCard({required this.pl});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return Container(
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
          Text(pl.desc, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: p.textSecondary)),
        ],
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
