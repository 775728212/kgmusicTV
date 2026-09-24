import 'package:flutter/material.dart';

/// 封面占位：渐变 + 首字 + 音符 + 装饰圆环。
/// [size] 为 null 时填满父级（父级需约束尺寸，如 Expanded/AspectRatio）。
class CoverArt extends StatelessWidget {
  final String name;
  final Color color;
  final String? url;
  final double? size;
  final double radius;
  final bool showRing;
  final double fontSize; // 0 = 按尺寸自动

  const CoverArt({
    super.key,
    required this.name,
    required this.color,
    this.url,
    this.size = 80,
    this.radius = 14,
    this.showRing = true,
    this.fontSize = 0,
  });

  @override
  Widget build(BuildContext context) {
    final c2 = Color.lerp(color, Colors.white, 0.25)!;
    final box = LayoutBuilder(
      builder: (context, constraints) {
        final s = size ?? constraints.biggest.shortestSide;
        final fs = fontSize > 0 ? fontSize : s * 0.42;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color, c2]),
            borderRadius: BorderRadius.circular(radius),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Center(
                child: Text(
                  name.isEmpty ? '♪' : name.characters.first,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.38),
                    fontSize: fs,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Center(
                child: Icon(Icons.music_note, color: Colors.white.withValues(alpha: 0.55), size: s * 0.44),
              ),
              if (showRing)
                Positioned(
                  right: -s * 0.2,
                  bottom: -s * 0.24,
                  child: Container(
                    width: s * 0.72,
                    height: s * 0.72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.32), width: s * 0.04),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );

    if (size != null) {
      return SizedBox(width: size, height: size, child: box);
    }
    return box;
  }
}
