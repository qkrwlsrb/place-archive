// [Domain Layer] — Geofencing 거리 감지 담당
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/capsule.dart';
import 'notification_service.dart';

class GeofenceService {
  static final GeofenceService _instance = GeofenceService._internal();
  factory GeofenceService() => _instance;
  GeofenceService._internal();

  static const double _radiusMeters = 100.0; // 100m 이내
  final NotificationService _notificationService = NotificationService();

  StreamSubscription<Position>? _positionSub;
  final Set<String> _notifiedIds = {}; // 이미 알림 보낸 캡슐 ID

  List<Capsule> _capsules = [];

  void updateCapsules(List<Capsule> capsules) {
    _capsules = capsules;
  }

  Future<void> start() async {
    await _notificationService.initialize();

    _positionSub?.cancel();
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20, // 20m 이동 시마다 체크
      ),
    ).listen((position) {
      _checkNearby(position);
    });
  }

  void _checkNearby(Position position) {
    for (final capsule in _capsules) {
      if (_notifiedIds.contains(capsule.id)) continue;

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        capsule.latitude,
        capsule.longitude,
      );

      if (distance <= _radiusMeters) {
        _notifiedIds.add(capsule.id);
        _notificationService.showGeofenceNotification(
          title: '📍 근처에 기억이 있어요!',
          body: capsule.memo.length > 40
              ? '${capsule.memo.substring(0, 40)}...'
              : capsule.memo,
        );
      }
    }
  }

  /// 앱 재시작 시 알림 상태 리셋 (같은 장소 재방문 감지)
  void resetNotified() {
    _notifiedIds.clear();
  }

  void stop() {
    _positionSub?.cancel();
    _positionSub = null;
  }
}
