import 'package:flutter/material.dart';

/// 调色板 —— 与 HTML 原型里的 CSS 变量一一对应。
/// 白天 = EchoMusic 粉白；夜晚 = 深色 + 粉色高亮。
class AppPalette {
  final Color background; // 页面底色
  final Color card; // 卡片
  final Color cardAlt; // 次级卡片
  final Color text; // 主文字
  final Color textSecondary; // 次文字
  final Color line; // 分割线
  final Color accent; // 强调色（粉）
  final Color accent2; // 强调色浅
  final Color purple; // 紫
  final Color accentSoft; // 强调浅底
  final Color rowHover; // 行悬停
  final Color nowLine; // 当前播放行底
  final Color playerBar; // 底部播放条
  final bool isDark;

  const AppPalette({
    required this.background,
    required this.card,
    required this.cardAlt,
    required this.text,
    required this.textSecondary,
    required this.line,
    required this.accent,
    required this.accent2,
    required this.purple,
    required this.accentSoft,
    required this.rowHover,
    required this.nowLine,
    required this.playerBar,
    required this.isDark,
  });

  static const light = AppPalette(
    background: Color(0xFFFDF1F5),
    card: Color(0xFFFFFFFF),
    cardAlt: Color(0xFFFFF7FA),
    text: Color(0xFF2B2430),
    textSecondary: Color(0xFF8A8394),
    line: Color(0xFFF3E3EA),
    accent: Color(0xFFFF5C8A),
    accent2: Color(0xFFFF8FB0),
    purple: Color(0xFF8F6FFF),
    accentSoft: Color(0xFFFFE9F0),
    rowHover: Color(0xFFFFF2F6),
    nowLine: Color(0xFFFFE1EA),
    playerBar: Color(0xFFFFFFFF),
    isDark: false,
  );

  static const dark = AppPalette(
    background: Color(0xFF171320),
    card: Color(0xFF241F2E),
    cardAlt: Color(0xFF2B2438),
    text: Color(0xFFF0EAF4),
    textSecondary: Color(0xFF9A92A8),
    line: Color(0xFF332C40),
    accent: Color(0xFFFF6D97),
    accent2: Color(0xFFFF8FB0),
    purple: Color(0xFF8F6FFF),
    accentSoft: Color(0xFF3A2A35),
    rowHover: Color(0xFF2E2739),
    nowLine: Color(0xFF3D2C38),
    playerBar: Color(0xFF241F2E),
    isDark: true,
  );

  /// 页面渐变（粉白 → 淡紫 → 淡蓝 / 深色对应）
  List<Color> get backgroundGradient => isDark
      ? const [Color(0xFF171320), Color(0xFF1D1826), Color(0xFF141824)]
      : const [Color(0xFFFDE7EF), Color(0xFFF7E8FF), Color(0xFFE6ECFF)];
}

/// 根据调色板生成 Material 3 主题。
ThemeData buildTheme(AppPalette p) {
  final scheme = ColorScheme.fromSeed(
    seedColor: p.accent,
    brightness: p.isDark ? Brightness.dark : Brightness.light,
  ).copyWith(
    primary: p.accent,
    secondary: p.purple,
    surface: p.card,
    onSurface: p.text,
    error: const Color(0xFFE5484D),
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.background,
    splashFactory: InkSparkle.splashFactory,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: p.text,
      displayColor: p.text,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: p.text,
    ),
    dividerTheme: DividerThemeData(color: p.line, thickness: 1),
    iconTheme: IconThemeData(color: p.text),
  );
}

/// 全局主题控制器：持有当前调色板，支持白天/夜晚切换。
class ThemeController extends ChangeNotifier {
  AppPalette _palette;
  ThemeController(this._palette);

  AppPalette get palette => _palette;
  bool get isDark => _palette.isDark;

  void setDark(bool dark) {
    if (_palette.isDark == dark) return;
    _palette = dark ? AppPalette.dark : AppPalette.light;
    notifyListeners();
  }

  void toggle() => setDark(!_palette.isDark);
}
