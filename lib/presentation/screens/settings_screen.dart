// [Presentation Layer] — 환경설정 화면 렌더링 담당
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../application/view_models/auth_view_model.dart';
import '../../application/view_models/capsule_view_model.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationEnabled = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationEnabled = prefs.getBool('notification_enabled') ?? true;
      _loading = false;
    });
  }

  Future<void> _toggleNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_enabled', value);
    setState(() => _notificationEnabled = value);
  }

  Future<void> _sendPasswordReset() async {
    final user = context.read<AuthViewModel>().user;
    if (user?.email == null) return;

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: user!.email!);
      if (!mounted) return;
      _showSnackBar('비밀번호 재설정 이메일을 보냈습니다 ✓');
    } catch (e) {
      _showSnackBar('이메일 전송 실패. 다시 시도해주세요.');
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('계정 삭제',
            style: GoogleFonts.gaegu(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark)),
        content: Text(
            '계정을 삭제하면 모든 기억이 사라집니다.\n정말 삭제할까요?',
            style: GoogleFonts.notoSans(
                fontSize: 14, color: AppTheme.textMedium, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('취소',
                style: GoogleFonts.notoSans(color: AppTheme.textLight)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('삭제',
                style: GoogleFonts.notoSans(
                    color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    try {
      await FirebaseAuth.instance.currentUser?.delete();
      if (!mounted) return;
      context.read<CapsuleViewModel>().stopWatching();
    } catch (e) {
      _showSnackBar('계정 삭제 실패. 재로그인 후 다시 시도해주세요.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.notoSans()),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      appBar: AppBar(
        backgroundColor: AppTheme.warmCream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppTheme.textMedium),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('환경설정',
            style: GoogleFonts.gaegu(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 알림
          _SectionTitle(title: '알림'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              SwitchListTile(
                title: Text('근처 기억 알림',
                    style: GoogleFonts.notoSans(
                        fontSize: 14, color: AppTheme.textDark)),
                subtitle: Text('저장된 캡슐 100m 이내 진입 시 알림',
                    style: GoogleFonts.notoSans(
                        fontSize: 12, color: AppTheme.textLight)),
                value: _notificationEnabled,
                activeColor: AppTheme.primary,
                onChanged: _toggleNotification,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 계정
          _SectionTitle(title: '계정'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.lock_reset_rounded,
                label: '비밀번호 재설정',
                subtitle: '이메일로 재설정 링크 전송',
                onTap: _sendPasswordReset,
              ),
              const Divider(height: 1, color: AppTheme.warmBorder),
              _SettingsTile(
                icon: Icons.logout_rounded,
                label: '로그아웃',
                onTap: () async {
                  context.read<CapsuleViewModel>().stopWatching();
                  await context.read<AuthViewModel>().signOut();
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 앱 정보
          _SectionTitle(title: '앱 정보'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                label: '버전',
                trailing: Text('1.0.0',
                    style: GoogleFonts.notoSans(
                        fontSize: 13, color: AppTheme.textLight)),
              ),
              const Divider(height: 1, color: AppTheme.warmBorder),
              _SettingsTile(
                icon: Icons.code_rounded,
                label: '기술 스택',
                trailing: Text('Flutter · Firebase',
                    style: GoogleFonts.notoSans(
                        fontSize: 12, color: AppTheme.textLight)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 위험 구역
          _SectionTitle(title: '위험 구역', color: Colors.red[300]!),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _confirmDeleteAccount,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.red[200]!),
              ),
              alignment: Alignment.center,
              child: Text('계정 삭제',
                  style: GoogleFonts.gaegu(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.red[400])),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color? color;

  const _SectionTitle({required this.title, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: GoogleFonts.gaegu(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color ?? AppTheme.textLight));
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.warmBorder),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppTheme.textMedium, size: 20),
      title: Text(label,
          style: GoogleFonts.notoSans(
              fontSize: 14, color: AppTheme.textDark)),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: GoogleFonts.notoSans(
                  fontSize: 12, color: AppTheme.textLight))
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppTheme.textLight)
              : null),
    );
  }
}
