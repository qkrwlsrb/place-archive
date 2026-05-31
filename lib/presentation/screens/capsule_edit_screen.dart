// [Presentation Layer] — 캡슐 수정 화면 렌더링 담당
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../application/view_models/capsule_view_model.dart';
import '../../domain/entities/capsule.dart';
import '../theme/app_theme.dart';

class CapsuleEditScreen extends StatefulWidget {
  final Capsule capsule;

  const CapsuleEditScreen({super.key, required this.capsule});

  @override
  State<CapsuleEditScreen> createState() => _CapsuleEditScreenState();
}

class _CapsuleEditScreenState extends State<CapsuleEditScreen> {
  late TextEditingController _memoController;
  late bool _isPublic;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController(text: widget.capsule.memo);
    _isPublic = widget.capsule.isPublic;
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_memoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('기억을 입력해주세요', style: GoogleFonts.notoSans()),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final success = await context.read<CapsuleViewModel>().updateCapsule(
          widget.capsule.id,
          memo: _memoController.text.trim(),
          isPublic: _isPublic,
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('수정 실패. 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('yyyy년 M월 d일', 'ko').format(widget.capsule.createdAt);

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
          '기억 수정',
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
              onPressed: _isSaving ? null : _save,
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: _isSaving
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
          Row(
            children: [
              Text(dateStr,
                  style: GoogleFonts.gaegu(
                      fontSize: 15, color: AppTheme.textMedium)),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(color: AppTheme.warmBorder, thickness: 1),
          const SizedBox(height: 12),

          // 메모 입력
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
                  fontSize: 17, color: AppTheme.textDark, height: 1.8),
              decoration: InputDecoration(
                hintText: '기억을 수정해보세요 ✦',
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
              title: Text('공개 기억',
                  style: GoogleFonts.gaegu(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark)),
              subtitle: Text('다른 사람도 이 기억을 볼 수 있어요',
                  style: GoogleFonts.notoSans(
                      fontSize: 12, color: AppTheme.textLight)),
              value: _isPublic,
              activeColor: AppTheme.primary,
              onChanged: (v) => setState(() => _isPublic = v),
            ),
          ),
          const SizedBox(height: 24),

          GestureDetector(
            onTap: _isSaving ? null : _save,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: _isSaving ? AppTheme.warmBeige : AppTheme.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                _isSaving ? '저장 중...' : '✦  수정 완료',
                style: GoogleFonts.gaegu(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
