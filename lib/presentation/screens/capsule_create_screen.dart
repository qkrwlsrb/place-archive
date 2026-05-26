// [Presentation Layer] — 캡슐 생성 화면 렌더링 담당
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/view_models/auth_view_model.dart';
import '../../application/view_models/capsule_view_model.dart';
import '../../domain/entities/capsule.dart';

class CapsuleCreateScreen extends StatefulWidget {
  const CapsuleCreateScreen({super.key});

  @override
  State<CapsuleCreateScreen> createState() => _CapsuleCreateScreenState();
}

class _CapsuleCreateScreenState extends State<CapsuleCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _memoController = TextEditingController();

  bool _isPublic = false;

  // TODO: Week 13 — geolocator 패키지로 실제 GPS 좌표 대체 예정
  static const double _dummyLat = 37.5665;
  static const double _dummyLng = 126.9780;

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final capsuleVm = context.read<CapsuleViewModel>();
    final authVm = context.read<AuthViewModel>();
    final userId = authVm.user!.uid;

    final capsule = Capsule(
      id: '', // Firestore에서 자동 생성
      userId: userId,
      latitude: _dummyLat,
      longitude: _dummyLng,
      memo: _memoController.text.trim(),
      photoUrls: [],
      isPublic: _isPublic,
      createdAt: DateTime.now(),
    );

    await capsuleVm.createCapsule(capsule);

    if (!mounted) return;

    if (capsuleVm.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('저장 실패: ${capsuleVm.error}'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('기억이 저장되었습니다 ✓')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final capsuleVm = context.watch<CapsuleViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('기억 남기기'),
        actions: [
          TextButton(
            onPressed: capsuleVm.isLoading ? null : _save,
            child: const Text(
              '저장',
              style: TextStyle(
                color: Color(0xFF1D9E75),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 현재 위치 표시 (더미)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFF1D9E75)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '현재 위치',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        Text(
                          '${_dummyLat.toStringAsFixed(4)}, ${_dummyLng.toStringAsFixed(4)}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'GPS 준비 중',
                      style: TextStyle(color: Colors.orange, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 메모 입력
            const Text(
              '이 장소에서의 기억',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _memoController,
              maxLines: 6,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: '이 장소에서 어떤 기억을 남기고 싶으신가요?',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return '메모를 입력해주세요';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // 공개 여부
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text('공개 캡슐'),
                subtitle: const Text('다른 사람도 이 기억을 볼 수 있어요'),
                value: _isPublic,
                activeColor: const Color(0xFF1D9E75),
                onChanged: (v) => setState(() => _isPublic = v),
              ),
            ),
            const SizedBox(height: 32),

            // 저장 버튼
            FilledButton.icon(
              onPressed: capsuleVm.isLoading ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1D9E75),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: capsuleVm.isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child:
                          CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                capsuleVm.isLoading ? '저장 중...' : '기억 저장하기',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
