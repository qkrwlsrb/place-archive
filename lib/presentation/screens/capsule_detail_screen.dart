// [Presentation Layer] — 캡슐 상세 화면 렌더링 담당
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/capsule.dart';
import '../theme/app_theme.dart';

class CapsuleDetailScreen extends StatelessWidget {
  final Capsule capsule;

  const CapsuleDetailScreen({super.key, required this.capsule});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy년 M월 d일 EEEE', 'ko').format(capsule.createdAt);
    final timeStr = DateFormat('HH:mm').format(capsule.createdAt);

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
        title: Text(
          '기억 보기',
          style: GoogleFonts.gaegu(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜 헤더
            Text(
              dateStr,
              style: GoogleFonts.gaegu(
                fontSize: 15,
                color: AppTheme.textMedium,
              ),
            ),
            Text(
              timeStr,
              style: GoogleFonts.gaegu(
                fontSize: 13,
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 4),
            const Divider(color: AppTheme.warmBorder),
            const SizedBox(height: 16),

            // 메모 본문
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.warmBorder),
              ),
              child: Text(
                capsule.memo,
                style: GoogleFonts.gaegu(
                  fontSize: 18,
                  color: AppTheme.textDark,
                  height: 1.9,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 위치 정보
            _InfoCard(
              icon: Icons.location_on_outlined,
              label: '위치',
              value:
                  '${capsule.latitude.toStringAsFixed(5)}, ${capsule.longitude.toStringAsFixed(5)}',
            ),
            const SizedBox(height: 10),

            // 공개 여부
            _InfoCard(
              icon: capsule.isPublic
                  ? Icons.public_rounded
                  : Icons.lock_outline_rounded,
              label: '공개 여부',
              value: capsule.isPublic ? '공개 기억' : '비공개 기억',
              valueColor:
                  capsule.isPublic ? AppTheme.primary : AppTheme.textLight,
            ),
            const SizedBox(height: 10),

            // 작성일
            _InfoCard(
              icon: Icons.schedule_rounded,
              label: '작성일',
              value: DateFormat('yyyy.MM.dd HH:mm').format(capsule.createdAt),
            ),
            const SizedBox(height: 32),

            // 하단 장식
            Center(
              child: Text(
                '✦  이 기억은 이곳에 영원히 남아있어요  ✦',
                style: GoogleFonts.gaegu(
                  fontSize: 13,
                  color: AppTheme.textLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warmBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textLight),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              color: AppTheme.textLight,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
