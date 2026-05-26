// [Domain Layer] — 위치 서비스 담당
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// 현재 GPS 위치를 반환합니다.
  /// 권한이 없으면 요청하고, 거부되면 예외를 던집니다.
  Future<Position> getCurrentPosition() async {
    // 위치 서비스 활성화 확인
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('위치 서비스가 꺼져 있습니다. 설정에서 켜주세요.');
    }

    // 권한 확인
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한이 거부되었습니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 영구적으로 거부되었습니다. 설정에서 직접 허용해주세요.');
    }

    // 위치 가져오기
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }
}
