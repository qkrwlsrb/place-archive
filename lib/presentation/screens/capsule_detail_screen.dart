// [Presentation Layer] — 캡슐 상세 화면 렌더링 담당
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../application/view_models/auth_view_model.dart';
import '../../application/view_models/capsule_view_model.dart';
import '../../domain/entities/capsule.dart';
import '../theme/app_theme.dart';
import 'capsule_edit_screen.dart';

class CapsuleDetailScreen extends StatelessWidget {
  final Capsule capsule;

  const CapsuleDetailScreen({super.key, required this.capsule});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('기억 삭제',
            style: GoogleFonts.gaegu(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark)),
        content: Text('이 기억을 삭제하면 복구할 수 없어요.\n정말 삭제할까요?',
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
    if (!context.mounted) return;

    final success =
        await context.read<CapsuleViewModel>().deleteCapsule(capsule);

    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('기억이 삭제되었습니다', style: GoogleFonts.notoSans()),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('yyyy년 M월 d일 EEEE', 'ko').format(capsule.createdAt);
    final timeStr = DateFormat('HH:mm').format(capsule.createdAt);
    final currentUserId = context.read<AuthViewModel>().user?.uid;
    final isOwner = currentUserId == capsule.userId;

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
        title: Text('기억 보기',
            style: GoogleFonts.gaegu(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark)),
        actions: [
          if (isOwner) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: AppTheme.primary, size: 22),
              tooltip: '수정',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CapsuleEditScreen(capsule: capsule),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Colors.red, size: 22),
              tooltip: '삭제',
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateStr,
                style: GoogleFonts.gaegu(
                    fontSize: 15, color: AppTheme.textMedium)),
            Text(timeStr,
                style: GoogleFonts.gaegu(
                    fontSize: 13, color: AppTheme.textLight)),
            const SizedBox(height: 4),
            const Divider(color: AppTheme.warmBorder),
            const SizedBox(height: 16),

            if (capsule.photoUrls.isNotEmpty) ...[
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: capsule.photoUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _showFullImage(context, index),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          capsule.photoUrls[index],
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              width: 200,
                              height: 200,
                              color: AppTheme.warmBeige,
                              child: const Center(
                                child: CircularProgressIndicator(
                                    color: AppTheme.primary),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.warmBorder),
              ),
              child: Text(capsule.memo,
                  style: GoogleFonts.gaegu(
                      fontSize: 18, color: AppTheme.textDark, height: 1.9)),
            ),
            const SizedBox(height: 20),

            _InfoCard(
              icon: Icons.location_on_outlined,
              label: '위치',
              value:
                  '${capsule.latitude.toStringAsFixed(5)}, ${capsule.longitude.toStringAsFixed(5)}',
            ),
            const SizedBox(height: 10),
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
            _InfoCard(
              icon: Icons.schedule_rounded,
              label: '작성일',
              value: DateFormat('yyyy.MM.dd HH:mm').format(capsule.createdAt),
            ),
            const SizedBox(height: 32),

            Center(
              child: Text('✦  이 기억은 이곳에 영원히 남아있어요  ✦',
                  style: GoogleFonts.gaegu(
                      fontSize: 13, color: AppTheme.textLight)),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullImageViewer(
          urls: capsule.photoUrls,
          initialIndex: initialIndex,
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
          Text(label,
              style: GoogleFonts.notoSans(
                  fontSize: 13, color: AppTheme.textLight)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.notoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppTheme.textDark)),
        ],
      ),
    );
  }
}

class _FullImageViewer extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;

  const _FullImageViewer({required this.urls, required this.initialIndex});

  @override
  State<_FullImageViewer> createState() => _FullImageViewerState();
}

class _FullImageViewerState extends State<_FullImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1} / ${widget.urls.length}',
            style: GoogleFonts.notoSans(color: Colors.white)),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.urls.length,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: Image.network(widget.urls[index], fit: BoxFit.contain),
            ),
          );
        },
      ),
    );
  }
}
