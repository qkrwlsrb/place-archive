// [Presentation Layer] — 캡슐 생성 화면 렌더링 담당
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../application/view_models/auth_view_model.dart';
import '../../application/view_models/capsule_view_model.dart';
import '../../domain/entities/capsule.dart';
import '../../domain/services/location_service.dart';
import '../theme/app_theme.dart';

class CapsuleCreateScreen extends StatefulWidget {
  const CapsuleCreateScreen({super.key});

  @override
  State<CapsuleCreateScreen> createState() => _CapsuleCreateScreenState();
}

class _CapsuleCreateScreenState extends State<CapsuleCreateScreen> {
  final _memoController = TextEditingController();
  final _locationService = LocationService();

  bool _isPublic = false;
  bool _locationLoading = false;
  Position? _currentPosition;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _locationLoading = true;
      _locationError = null;
    });
    try {
      final position = await _locationService.getCurrentPosition();
      setState(() => _currentPosition = position);
    } catch (e) {
      setState(() => _locationError = e.toString());
    } finally {
      setState(() => _locationLoading = false);
    }
  }

  Future<void> _save() async {
    if (_memoController.text.trim().isEmpty) {
      _showSnackBar('기억을 입력해주세요');
      return;
    }
    if (_currentPosition == null) {
      _showSnackBar('위치 정보를 불러오는 중입니다. 잠시 후 다시 시도해주세요.');
      return;
    }

    final capsuleVm = context.read<CapsuleViewModel>();
    final authVm = context.read<AuthViewModel>();

    final capsule = Capsule(
      id: '',
      userId: authVm.user!.uid,
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      memo: _memoController.text.trim(),
      photoUrls: [],
      isPublic: _isPublic,
      createdAt: DateTime.now(),
    );

    await capsuleVm.createCapsule(capsule);
    if (!mounted) return;

    if (capsuleVm.error != null) {
      _showSnackBar('저장 실패: ${capsuleVm.error}');
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.notoSans()),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final capsuleVm = context.watch<CapsuleViewModel>();
    final dateStr = DateFormat('yyyy년 M월 d일', 'ko').format(DateTime.now());

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
          '기억 남기기',
          style: GoogleFonts.gaegu(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: capsuleVm.isLoading ? null : _save,
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: capsuleVm.isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text('저장',
                      style: GoogleFonts.gaegu(
                          fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 날짜 + 위치 정보
          Row(
            children: [
              Text(
                dateStr,
                style: GoogleFonts.gaegu(
                    fontSize: 15, color: AppTheme.textMedium),
              ),
              const SizedBox(width: 8),
              _buildLocationBadge(),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(color: AppTheme.warmBorder, thickness: 1),
          const SizedBox(height: 12),

          // 텍스트 입력
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.warmBorder),
            ),
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _memoController,
              maxLines: 12,
              maxLength: 500,
              style: GoogleFonts.gaegu(
                fontSize: 17,
                color: AppTheme.textDark,
                height: 1.8,
              ),
              decoration: InputDecoration(
                hintText:
                    '이 장소에서 어떤 기억을 남기고 싶으신가요?\n\n오늘의 날씨, 함께한 사람, 그때의 감정을 적어보세요 ✦',
                hintStyle: GoogleFonts.gaegu(
                    fontSize: 15, color: AppTheme.textLight, height: 1.8),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                counterStyle: GoogleFonts.notoSans(
                    fontSize: 11, color: AppTheme.textLight),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 공개 여부
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.warmBorder),
            ),
            child: SwitchListTile(
              title: Text(
                '공개 기억',
                style: GoogleFonts.gaegu(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark),
              ),
              subtitle: Text(
                '다른 사람도 이 기억을 볼 수 있어요',
                style: GoogleFonts.notoSans(
                    fontSize: 12, color: AppTheme.textLight),
              ),
              value: _isPublic,
              activeColor: AppTheme.primary,
              onChanged: (v) => setState(() => _isPublic = v),
            ),
          ),
          const SizedBox(height: 24),

          // 저장 버튼
          GestureDetector(
            onTap: capsuleVm.isLoading ? null : _save,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: capsuleVm.isLoading
                    ? AppTheme.warmBeige
                    : AppTheme.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                capsuleVm.isLoading ? '저장 중...' : '✦  이 기억 저장하기',
                style: GoogleFonts.gaegu(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationBadge() {
    if (_locationLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                  strokeWidth: 1.5, color: AppTheme.primary),
            ),
            const SizedBox(width: 6),
            Text('위치 찾는 중...',
                style: GoogleFonts.notoSans(
                    fontSize: 11, color: AppTheme.primary)),
          ],
        ),
      );
    }

    if (_locationError != null) {
      return GestureDetector(
        onTap: _fetchLocation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0EC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFCDBD)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.refresh_rounded,
                  size: 12, color: Color(0xFFB85C38)),
              const SizedBox(width: 4),
              Text('위치 재시도',
                  style: GoogleFonts.notoSans(
                      fontSize: 11, color: const Color(0xFFB85C38))),
            ],
          ),
        ),
      );
    }

    if (_currentPosition != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on_rounded,
                size: 11, color: AppTheme.primary),
            const SizedBox(width: 4),
            Text(
              '${_currentPosition!.latitude.toStringAsFixed(4)}, '
              '${_currentPosition!.longitude.toStringAsFixed(4)}',
              style: GoogleFonts.notoSans(
                  fontSize: 11, color: AppTheme.primary),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
