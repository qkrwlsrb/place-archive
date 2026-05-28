// [Application Layer] — 캡슐 상태 관리 담당
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/capsule.dart';
import '../../data/repositories/capsule_repository.dart';

class CapsuleViewModel extends ChangeNotifier {
  final CapsuleRepository _repo;

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
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
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
    super.dispose();
  }
}
