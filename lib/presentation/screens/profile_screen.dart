// [Presentation Layer] — 프로필 화면 렌더링 담당
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../application/view_models/auth_view_model.dart';
import '../../application/view_models/capsule_view_model.dart';
import '../theme/app_theme.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final capsuleVm = context.watch<CapsuleViewModel>();
    final user = auth.user;
    final capsules = capsuleVm.capsules;

    final totalCapsules = capsules.length;
    final publicCount = capsules.where((c) => c.isPublic).length;
    final privateCount = capsules.where((c) => !c.isPublic).length;
    final photoCount =
        capsules.fold<int>(0, (sum, c) => sum + c.photoUrls.length);
    final lastCapsule = capsules.isNotEmpty ? capsules.first : null;

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppTheme.warmCream,
            floating: true,
            snap: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text('내 프로필',
                style: GoogleFonts.gaegu(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark)),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined,
                    size: 22, color: AppTheme.textMedium),
                tooltip: '환경설정',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(user?.email ?? ''),
                  const SizedBox(height: 20),

                  Text('나의 기억 통계',
                      style: GoogleFonts.gaegu(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark)),
                  const SizedBox(height: 12),
                  _buildStatsGrid(
                      totalCapsules, publicCount, privateCount, photoCount),
                  const SizedBox(height: 24),

                  if (lastCapsule != null) ...[
                    Text('가장 최근 기억',
                        style: GoogleFonts.gaegu(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark)),
                    const SizedBox(height: 12),
                    _buildLastCapsuleCard(lastCapsule.memo,
                        lastCapsule.createdAt, lastCapsule.photoUrls.isNotEmpty),
                    const SizedBox(height: 24),
                  ],

                  Text('계정 정보',
                      style: GoogleFonts.gaegu(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark)),
                  const SizedBox(height: 12),
                  _buildAccountInfo(user?.email ?? '', user?.uid ?? ''),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(String email) {
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.warmBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
                color: AppTheme.primary, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(initial,
                style: GoogleFonts.gaegu(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(email.split('@').first,
                    style: GoogleFonts.gaegu(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark)),
                const SizedBox(height: 4),
                Text(email,
                    style: GoogleFonts.notoSans(
                        fontSize: 12, color: AppTheme.textLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(int total, int pub, int priv, int photos) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _StatCard(icon: '📝', label: '전체 기억', value: '$total개'),
        _StatCard(icon: '🌍', label: '공개 기억', value: '$pub개'),
        _StatCard(icon: '🔒', label: '비공개 기억', value: '$priv개'),
        _StatCard(icon: '📷', label: '첨부 사진', value: '$photos장'),
      ],
    );
  }

  Widget _buildLastCapsuleCard(String memo, DateTime date, bool hasPhoto) {
    final dateStr = DateFormat('yyyy년 M월 d일', 'ko').format(date);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.warmBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(dateStr,
                  style: GoogleFonts.notoSans(
                      fontSize: 12, color: AppTheme.textMedium)),
              const Spacer(),
              if (hasPhoto) const Text('📷', style: TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(memo,
              style: GoogleFonts.gaegu(
                  fontSize: 16, color: AppTheme.textDark, height: 1.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildAccountInfo(String email, String uid) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.warmBorder),
      ),
      child: Column(
        children: [
          _InfoRow(label: '이메일', value: email),
          const Divider(height: 1, color: AppTheme.warmBorder),
          _InfoRow(
              label: '사용자 ID',
              value: uid.length > 12 ? '${uid.substring(0, 12)}...' : uid),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatCard(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.warmBorder),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  style: GoogleFonts.notoSans(
                      fontSize: 11, color: AppTheme.textLight)),
              Text(value,
                  style: GoogleFonts.gaegu(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(label,
              style: GoogleFonts.notoSans(
                  fontSize: 13, color: AppTheme.textLight)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.notoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark)),
        ],
      ),
    );
  }
}
