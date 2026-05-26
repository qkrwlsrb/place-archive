# ADR-0001: 모바일 플랫폼 선택

- **날짜**: 2026-05-19
- **상태**: 확정

## 결정
**Flutter** (크로스플랫폼)를 선택한다.

## 고려한 대안
| 대안 | 검토 결과 |
|------|-----------|
| React Native | JS/TS 생태계 익숙하지 않음 |
| Android (Kotlin) | iOS 지원 불가 |
| iOS (Swift) | macOS 필수, Android 지원 불가 |

## 결정 이유
- 한 코드베이스로 iOS · Android 동시 지원
- Google Maps, Firebase 패키지 Flutter 생태계에서 성숙
- Dart 학습 곡선 낮아 초급자에게 적합

## 결과
- Flutter 3.16.x 이상 사용
