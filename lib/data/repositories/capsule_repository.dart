// [Data Layer] — Firestore 캡슐 데이터 호출 담당
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/entities/capsule.dart';

class CapsuleRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
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

  /// 공개 캡슐 실시간 스트림 (최신순)
  Stream<List<Capsule>> watchPublicCapsules() {
    return _db
        .collection(_collection)
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => Capsule.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  /// 캡슐 생성
  Future<void> createCapsule(Capsule capsule) async {
    final data = capsule.toJson()..remove('id');
    await _db.collection(_collection).add(data);
  }

  /// 캡슐 삭제 (사진도 Storage에서 함께 삭제)
  Future<void> deleteCapsule(Capsule capsule) async {
    // Firestore 문서 삭제
    await _db.collection(_collection).doc(capsule.id).delete();

    // Storage 사진 삭제
    for (final url in capsule.photoUrls) {
      try {
        final ref = _storage.refFromURL(url);
        await ref.delete();
      } catch (_) {
        // 사진 삭제 실패해도 계속 진행
      }
    }
  }
}
