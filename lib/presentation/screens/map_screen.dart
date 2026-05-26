// [Presentation Layer] — 지도 화면 렌더링 담당
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../application/view_models/auth_view_model.dart';
import '../../application/view_models/capsule_view_model.dart';
import '../../domain/entities/capsule.dart';
import 'capsule_create_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 현재 유저의 캡슐 구독 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthViewModel>().user?.uid;
      if (userId != null) {
        context.read<CapsuleViewModel>().startWatching(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final capsuleVm = context.watch<CapsuleViewModel>();
    final email = auth.user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('장소 기억 아카이브'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '로그아웃',
            onPressed: () async {
              context.read<CapsuleViewModel>().stopWatching();
              await auth.signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 지도 영역 placeholder (Week 13에 google_maps_flutter로 교체 예정)
          Container(
            width: double.infinity,
            height: 220,
            color: Colors.grey[100],
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      '지도 영역 (Google Maps 연동 예정)',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        )
                      ],
                    ),
                    child: Text(
                      email,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 캡슐 목록 헤더
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text(
                  '내 기억',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                if (!capsuleVm.isLoading)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D9E75).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${capsuleVm.capsules.length}개',
                      style: const TextStyle(
                        color: Color(0xFF1D9E75),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 캡슐 목록
          Expanded(
            child: _buildCapsuleList(capsuleVm),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CapsuleCreateScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_location_alt),
        label: const Text('기억 남기기'),
      ),
    );
  }

  Widget _buildCapsuleList(CapsuleViewModel capsuleVm) {
    if (capsuleVm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (capsuleVm.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(capsuleVm.error!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      );
    }

    if (capsuleVm.capsules.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_location_alt_outlined,
                size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            const Text(
              '아직 남긴 기억이 없어요',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            const Text(
              '아래 버튼을 눌러 첫 기억을 남겨보세요',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: capsuleVm.capsules.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) =>
          _CapsuleCard(capsule: capsuleVm.capsules[index]),
    );
  }
}

class _CapsuleCard extends StatelessWidget {
  final Capsule capsule;

  const _CapsuleCard({required this.capsule});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy.MM.dd HH:mm').format(capsule.createdAt);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜 + 공개여부
            Row(
              children: [
                Icon(Icons.schedule, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  dateStr,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: capsule.isPublic
                        ? const Color(0xFF1D9E75).withOpacity(0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    capsule.isPublic ? '공개' : '비공개',
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          capsule.isPublic ? const Color(0xFF1D9E75) : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 메모
            Text(
              capsule.memo,
              style: const TextStyle(fontSize: 14, height: 1.5),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            // 위치
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  '${capsule.latitude.toStringAsFixed(4)}, ${capsule.longitude.toStringAsFixed(4)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
