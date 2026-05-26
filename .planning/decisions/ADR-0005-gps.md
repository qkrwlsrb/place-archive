# ADR-0005: GPS 위치 서비스 라이브러리 선택

- **날짜**: 2026-05-26
- **상태**: 확정

## 결정
**geolocator** 패키지를 GPS 위치 수집에 사용한다.

## 고려한 대안
| 대안 | 검토 결과 |
|------|-----------|
| location 패키지 | geolocator보다 API가 단순하지만 기능 제한적 |
| flutter_map_location_marker | 지도 마커 전용, 단독 위치 수집 불가 |
| 직접 네이티브 구현 | 플랫폼별 코드 필요, 유지보수 부담 |

## 결정 이유
- Flutter 생태계에서 가장 많이 사용되는 GPS 패키지
- iOS/Android 권한 요청 처리 내장
- 정확도 설정, 타임아웃 등 세밀한 제어 가능
- 지속적으로 유지보수되는 패키지

## 결과
- `geolocator: ^13.0.2` 사용
- `LocationService`를 `domain/services/`에 위치시켜 레이어드 아키텍처 준수
- Android: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` 권한 추가
- 위치 권한 거부 시 서울 기본 좌표(37.5665, 126.9780) 폴백 처리
