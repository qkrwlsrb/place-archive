import 'package:flutter/foundation.dart';
import '../../domain/entities/capsule.dart';

class CapsuleViewModel extends ChangeNotifier {
  List<Capsule> _capsules = [];
  bool _isLoading = false;
  String? _error;

  List<Capsule> get capsules => _capsules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMyCapsules(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _capsules = [];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCapsule(Capsule capsule) async {
    _isLoading = true;
    notifyListeners();
    try {
      _capsules = [..._capsules, capsule];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
