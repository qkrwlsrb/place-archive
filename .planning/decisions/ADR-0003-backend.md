# ADR-0003: 백엔드 및 데이터 저장소 선택

- **날짜**: 2026-05-19
- **상태**: 확정

## 결정
**Firebase** (Firestore + Storage + Auth)를 백엔드로 선택한다.

## 고려한 대안
| 대안 | 검토 결과 |
|------|-----------|
| Supabase | Flutter SDK 성숙도가 낮음 |
| AWS Amplify | 설정 복잡도 높음 |
| 직접 REST API | 서버 개발 공수 과도 |

## 결정 이유
- Flutter 공식 통합 SDK 제공
- Firestore 실시간 동기화
- Google/Apple 소셜 로그인 즉시 사용 가능
- Spark 무료 플랜으로 충분

## 결과
- google-services.json은 .gitignore에 포함
