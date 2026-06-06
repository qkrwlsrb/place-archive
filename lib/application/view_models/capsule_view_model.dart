// [Application Layer] — 캡슐 상태 관리 담당
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/capsule.dart';
import '../../data/repositories/capsule_repository.dart';
import '../../domain/services/geofence_service.dart';

class CapsuleViewModel extends ChangeNotifier {
  final CapsuleRepository _repo;
  final GeofenceService _geofence = GeofenceService();

  List<Capsule> _capsules = [];
  List<Capsule> _publicCapsules = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Capsule>>? _capsulesub;
  StreamSubscription<List<Capsule>>? _publicSub;

  CapsuleViewModel(this._repo);

  List<Capsule> get capsules => _capsules;
  List<Capsule> get publicCapsules => _publicCapsules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void startWatching(String userId) {
    _isLoading = true;
    notifyListeners();
    _capsulesub?.cancel();
    _capsulesub = _repo.watchUserCapsules(userId).listen(
      (capsules) {
        _capsules = capsules;
        _isLoading = false;
        _error = null;
        // Geofence에 최신 캡슐 목록 전달
        _geofence.updateCapsules(capsules);
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
    // Geofence 시작
    _geofence.start();
  }

  void startWatchingPublic() {
    _publicSub?.cancel();
    _publicSub = _repo.watchPublicCapsules().listen(
      (capsules) {
        _publicCapsules = capsules;
        notifyListeners();
      },
    );
  }

  void stopWatching() {
    _capsulesub?.cancel();
    _publicSub?.cancel();
    _geofence.stop();
    _capsules = [];
    _publicCapsules = [];
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createCapsule(Capsule capsule) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.createCapsule(capsule);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCapsule(String capsuleId,
      {required String memo, required bool isPublic}) async {
    try {
      await _repo.updateCapsule(capsuleId, memo: memo, isPublic: isPublic);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCapsule(Capsule capsule) async {
    try {
      await _repo.deleteCapsule(capsule);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _capsulesub?.cancel();
    _publicSub?.cancel();
    _geofence.stop();
    super.dispose();
  }
}
