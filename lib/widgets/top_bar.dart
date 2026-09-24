import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// 顶部栏：搜索框 + 刷新/设置 + 登录按钮。
class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final p = context.watch<ThemeController>().palette;

    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 34),
      decoration: BoxDecoration(
        color: p.card.withValues(alpha: p.isDark ? 0.72 : 0.66),
        border: Border(bottom: BorderSide(color: p.line)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: InkWell(
              onTap: () => app.go(NavPage.search),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                decoration: BoxDecoration(
                  color: p.card,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: p.accent.withValues(alpha: 0.10), blurRadius: 30, offset: const Offset(0, 8))],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, size: 22, color: p.textSecondary),
                    const SizedBox(width: 12),
                    Text('搜索歌曲、歌手、专辑…', style: TextStyle(fontSize: 19, color: p.textSecondary)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          _IconBtn(icon: Icons.refresh_rounded, p: p, onTap: () {}),
          const SizedBox(width: 14),
          _IconBtn(icon: Icons.settings_rounded, p: p, onTap: () {}),
          const SizedBox(width: 16),
          if (!app.loggedIn)
            FilledButton(
              onPressed: () => _showLogin(context),
              style: FilledButton.styleFrom(
                backgroundColor: p.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              child: const Text('登录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            )
          else
            CircleAvatar(radius: 22, backgroundColor: p.accent, child: Text('🐶', style: const TextStyle(fontSize: 20))),
        ],
      ),
    );
  }

  void _showLogin(BuildContext context) {
    showDialog(context: context, builder: (_) => const LoginDialog());
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final AppPalette p;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.p, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(color: p.card, shape: BoxShape.circle, boxShadow: [
          BoxShadow(color: p.accent.withValues(alpha: 0.10), blurRadius: 30, offset: const Offset(0, 8)),
        ]),
        child: Icon(icon, size: 24, color: p.text),
      ),
    );
  }
}

/// 登录弹窗（手机号 + 验证码）。
class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return Dialog(
      backgroundColor: p.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('登录酷狗音乐', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: p.text)),
              const SizedBox(height: 10),
              Text('手机号 + 验证码登录（/login/phone）', style: TextStyle(fontSize: 15, color: p.textSecondary)),
              const SizedBox(height: 28),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                decoration: _dec(p, '请输入手机号'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextField(controller: _code, keyboardType: TextInputType.number, decoration: _dec(p, '请输入验证码'))),
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 140,
                    height: 60,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: p.accent,
                        backgroundColor: p.accentSoft,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('获取验证码', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: FilledButton(
                  onPressed: _loading ? null : _login,
                  style: FilledButton.styleFrom(
                    backgroundColor: p.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: _loading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('登 录', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(AppPalette p, String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: p.textSecondary),
        filled: true,
        fillColor: p.cardAlt,
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: p.line, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: p.accent, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
      );

  Future<void> _login() async {
    setState(() => _loading = true);
    final ok = await context.read<AppState>().login(_phone.text, _code.text);
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pop();
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('手机号或验证码有误（模拟）')));
    }
  }
}
