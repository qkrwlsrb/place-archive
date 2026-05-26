// [Data Layer] — Firestore 캡슐 데이터 호출 담당
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/capsule.dart';

class CapsuleRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _collection = 'capsules';

  /// 내 캡슐 실시간 스트림 (최신순)
  Stream<List<Capsule>> watchUserCapsules(String userId) {
    return _db
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => Capsule.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  /// 캡슐 생성 (Firestore가 ID 자동 생성)
  Future<void> createCapsule(Capsule capsule) async {
    final data = capsule.toJson()..remove('id'); // id는 Firestore 문서 ID로 관리
    await _db.collection(_collection).add(data);
  }
}
