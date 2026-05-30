// [Presentation Layer] — 공개 기억 피드 화면 렌더링 담당
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../application/view_models/capsule_view_model.dart';
import '../../domain/entities/capsule.dart';
import '../theme/app_theme.dart';
import 'capsule_detail_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CapsuleViewModel>().startWatchingPublic();
    });
  }

  @override
  Widget build(BuildContext context) {
    final capsuleVm = context.watch<CapsuleViewModel>();

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
            title: Text(
              '모두의 기억',
              style: GoogleFonts.gaegu(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Text(
                '사람들이 남긴\n소중한 장소의 기억들 ✦',
                style: GoogleFonts.gaegu(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                  height: 1.4,
                ),
              ),
            ),
          ),

          _buildFeed(capsuleVm),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildFeed(CapsuleViewModel capsuleVm) {
    if (capsuleVm.publicCapsules.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🌍', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text('아직 공개된 기억이 없어요',
                  style: GoogleFonts.gaegu(
                      fontSize: 16, color: AppTheme.textMedium)),
              const SizedBox(height: 4),
              Text('첫 번째로 기억을 공개해보세요',
                  style: GoogleFonts.notoSans(
                      fontSize: 12, color: AppTheme.textLight)),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList.separated(
        itemCount: capsuleVm.publicCapsules.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            _FeedCard(capsule: capsuleVm.publicCapsules[index]),
      ),
    );
  }
}

class _FeedCard extends StatelessWidget {
  final Capsule capsule;
  const _FeedCard({required this.capsule});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy.MM.dd HH:mm').format(capsule.createdAt);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CapsuleDetailScreen(capsule: capsule),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.warmBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사진이 있으면 표시
            if (capsule.photoUrls.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Image.network(
                  capsule.photoUrls.first,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 180,
                      color: AppTheme.warmBeige,
                      child: const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primary),
                      ),
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 날짜 + 위치
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: AppTheme.textLight),
                      const SizedBox(width: 3),
                      Text(
                        '${capsule.latitude.toStringAsFixed(3)}, '
                        '${capsule.longitude.toStringAsFixed(3)}',
                        style: GoogleFonts.notoSans(
                            fontSize: 10, color: AppTheme.textLight),
                      ),
                      const Spacer(),
                      Text(dateStr,
                          style: GoogleFonts.notoSans(
                              fontSize: 10, color: AppTheme.textLight)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 메모
                  Text(
                    capsule.memo,
                    style: GoogleFonts.gaegu(
                        fontSize: 15, color: AppTheme.textDark, height: 1.5),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('자세히 보기 →',
                          style: GoogleFonts.notoSans(
                              fontSize: 10, color: AppTheme.primary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
