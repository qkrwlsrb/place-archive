// [Application Layer] — 인증 상태 관리 담당
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repo;

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  User? _user;
  StreamSubscription<User?>? _authSub;

  AuthViewModel(this._repo) {
    // Firebase 인증 상태 변화를 자동으로 감지
    _authSub = _repo.authStateChanges.listen((user) {
      _user = user;
      _status = user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
      notifyListeners();
    });
  }

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> signIn(String email, String password) async {
    _setLoading();
    try {
      await _repo.signIn(email, password);
      // 성공 시 authStateChanges 스트림이 자동으로 status를 authenticated로 변경
    } on FirebaseAuthException catch (e) {
      _setError(_mapErrorCode(e.code));
    }
  }

  Future<void> signUp(String email, String password) async {
    _setLoading();
    try {
      await _repo.signUp(email, password);
    } on FirebaseAuthException catch (e) {
      _setError(_mapErrorCode(e.code));
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = AuthStatus.error;
    notifyListeners();
  }

  String _mapErrorCode(String code) {
    switch (code) {
      case 'user-not-found':
        return '등록되지 않은 이메일입니다.';
      case 'wrong-password':
      case 'invalid-credential':
        return '이메일 또는 비밀번호가 올바르지 않습니다.';
      case 'invalid-email':
        return '이메일 형식이 올바르지 않습니다.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'weak-password':
        return '비밀번호는 6자 이상이어야 합니다.';
      case 'too-many-requests':
        return '잠시 후 다시 시도해주세요.';
      default:
        return '오류가 발생했습니다. 다시 시도해주세요. ($code)';
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
