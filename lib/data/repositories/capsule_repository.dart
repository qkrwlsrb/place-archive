// [Data Layer] — Firestore 캡슐 데이터 호출 담당
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/entities/capsule.dart';

class CapsuleRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static const _collection = 'capsules';

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

  Future<void> createCapsule(Capsule capsule) async {
    final data = capsule.toJson()..remove('id');
    await _db.collection(_collection).add(data);
  }

  /// 캡슐 수정 (메모, 공개여부만 수정 가능)
  Future<void> updateCapsule(String capsuleId,
      {required String memo, required bool isPublic}) async {
    await _db.collection(_collection).doc(capsuleId).update({
      'memo': memo,
      'isPublic': isPublic,
    });
  }

  Future<void> deleteCapsule(Capsule capsule) async {
    await _db.collection(_collection).doc(capsule.id).delete();
    for (final url in capsule.photoUrls) {
      try {
        final ref = _storage.refFromURL(url);
        await ref.delete();
      } catch (_) {}
    }
  }
}
