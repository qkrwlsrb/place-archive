// [Application Layer] — 캡슐 상태 관리 담당
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/capsule.dart';
import '../../data/repositories/capsule_repository.dart';

class CapsuleViewModel extends ChangeNotifier {
  final CapsuleRepository _repo;

  List<Capsule> _capsules = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Capsule>>? _capsulesub;

  CapsuleViewModel(this._repo);

  List<Capsule> get capsules => _capsules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 로그인 후 해당 유저의 캡슐을 실시간으로 구독
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

  /// 구독 종료 (로그아웃 시 호출)
  void stopWatching() {
    _capsulesub?.cancel();
    _capsules = [];
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createCapsule(Capsule capsule) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.createCapsule(capsule);
      // 성공 시 Firestore 스트림이 자동으로 목록을 업데이트함
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _capsulesub?.cancel();
    super.dispose();
  }
}
