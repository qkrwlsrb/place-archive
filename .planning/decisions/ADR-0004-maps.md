# ADR-0004: 지도 라이브러리 선택

- **날짜**: 2026-05-26
- **상태**: 확정

## 결정
**google_maps_flutter** 패키지를 지도 렌더링에 사용한다.

## 고려한 대안
| 대안 | 검토 결과 |
|------|-----------|
| flutter_map + OpenStreetMap | 무료지만 한국 지도 데이터 품질이 낮음 |
| Naver Maps SDK | Flutter 공식 패키지 없음, 연동 복잡 |
| Kakao Maps SDK | Flutter 지원 미흡 |

## 결정 이유
- 한국 지도 데이터 품질이 압도적으로 우수
- Flutter 공식 Google 패키지로 안정성 보장
- 캡슐 마커, 커스텀 InfoWindow 등 필요 기능 지원
- Google Maps Platform 월 $200 무료 크레딧으로 개인 프로젝트 수준에서 사실상 무료

## 결과
- `google_maps_flutter: ^2.9.0` 사용
- API 키는 `android/app/src/main/AndroidManifest.xml`의 `meta-data`로 관리
- API 키는 `.gitignore`에 포함하지 않고 별도 관리 필요 (배포 시 키 제한 설정)
