# AGENTS.md — AI 협업 맥락 가이드

이 문서는 Claude Code, GitHub Copilot 등 AI Agent가 이 프로젝트를 **일관된 맥락**으로
이해하고 작업할 수 있도록 직접 작성한 컨텍스트 가이드입니다.
새 대화를 시작하기 전에 AI에게 이 파일을 먼저 읽히세요.

---

## 프로젝트 개요

**장소 기억 아카이브** — GPS로 현재 위치를 자동 기록하며 사진과 메모로 기억을 남기는
위치 기반 타임캡슐 Flutter 앱. 같은 장소를 다시 방문했을 때 과거의 기억을 꺼내볼 수 있다.

- 타겟: 20대, 다이어리 감성 컨셉
- 학번/이름: 2024136075 박진규 (Vibe Coding Project)
- 저장소: `C:/project/place_archive` (영어 경로 필수 — 한글 경로 빌드 불가)

---

## 아키텍처 원칙 (변경 금지)

레이어드 아키텍처. **의존 방향은 항상 위→아래**이며 역방향 의존은 절대 금지.

```
Presentation  →  Application  →  Domain
                              ↓
                            Data  →  Firebase
```

| 레이어 | 경로 | 역할 |
|--------|------|------|
| Presentation | `lib/presentation/` | UI 화면, 위젯 |
| Application  | `lib/application/`  | ViewModel, Provider 상태관리 |
| Domain       | `lib/domain/`       | Entity, Service (Firebase 미의존) |
| Data         | `lib/data/`         | Repository, Firebase 실제 호출 |

각 파일 상단에 레이어 주석 필수:
```dart
// [Presentation Layer] — 화면 렌더링 담당
// [Application Layer] — 상태 관리 담당
// [Domain Layer] — 비즈니스 규칙 담당
// [Data Layer] — API/DB 호출 담당
```

---

## 이미 결정된 기술 선택 (재논의 불필요)

ADR 파일(`.planning/decisions/`) 참고. 아래 결정은 확정이며 대안 제안 불필요.

| ADR | 결정 | 이유 요약 |
|-----|------|-----------|
| ADR-0001 | Flutter | iOS+Android 단일 코드베이스 |
| ADR-0002 | Provider (상태관리) | 공식 권장, 학습 부담 최소 |
| ADR-0003 | Firebase (Auth+Firestore+Storage) | 통합 백엔드, 실시간 동기화 |
| ADR-0004 | Google Maps Flutter | 한국 지도 데이터 품질 |
| ADR-0005 | Geolocator | Flutter 최다 사용 GPS 패키지 |
| ADR-0006 | 다이어리 감성 UI | 타겟 컨셉 일관성 |

**금지 제안 목록:** Riverpod, Bloc, GetX, Supabase, Hive, OpenStreetMap, iOS 전용 기능

---

## 구현 완료 기능 (중복 구현 방지)

- Firebase Auth 이메일/비밀번호 로그인, 비밀번호 재설정
- AuthGate 자동 라우팅 (`authStateChanges` 스트림 구독)
- Google Maps 마커 표시 및 탭 인터랙션
- Geolocator GPS 위치 수집 (권한 처리 포함)
- Firestore CRUD + `Stream` 실시간 동기화
- Firebase Storage 사진 업로드/조회
- Geofencing — 100m 이내 진입 감지 + 로컬 알림 (`flutter_local_notifications`)
- 공개 피드 (다른 사용자 캡슐 탐색)
- 검색 + 하이라이트
- 프로필 & 통계 화면
- IndexedStack 탭 전환 최적화, Stream `cancel()` 메모리 누수 방지

---

## 제약사항 (AI가 반드시 알아야 할 것)

1. **한글 경로 절대 금지** — 빌드 환경이 `C:/project/place_archive`. 한글 경로 권장 금지.
2. **Firebase MVP 3종만** — Firestore, Auth, Storage. 다른 Firebase 서비스 제안 금지.
3. **Android 타겟만** — iOS 빌드 환경 없음. Android 에뮬레이터 + 실기기만 고려.
4. **에뮬레이터 RAM** — AVD RAM 4GB 필수 (2GB에서 크래시 발생).

---

## 알려진 이슈 & 해결책 (재발 방지)

| 문제 | 원인 | 해결책 |
|------|------|--------|
| pubspec.yaml 파싱 오류 | Git 충돌 마커 잔존 | 파일 직접 덮어쓰기 |
| Windows 빌드 실패 | 경로에 한글(징규) 포함 | 영어 경로(`C:/project`)로 이동 |
| Firebase Windows 빌드 실패 | C++ SDK 요구 | MVP에서 제거 후 단계적으로 추가 |
| 에뮬레이터 offline | AVD 경로에 한글 포함 | `ANDROID_AVD_HOME` 환경변수 영어 경로로 설정 |
| Firestore 복합 쿼리 오류 | `where + orderBy` 인덱스 미생성 | Firebase Console에서 복합 인덱스 수동 생성 |
| Android v1 Embedding 오류 | android 폴더 구조 누락 | `flutter create`로 android 폴더 재생성 |

---

## AI 작업 가이드

### 코드 생성 시
- ViewModel에서 Firebase 직접 호출 금지 → Repository를 반드시 거칠 것
- 새 기능은 기존 레이어 구조에 맞는 파일 위치에 배치
- 빌드 오류 발생 시 **한글 경로 여부를 제일 먼저** 확인

### 디버깅 시
- Firestore 오류 → 복합 인덱스 문제 우선 의심
- pubspec.yaml 오류 → Git 충돌 마커 잔존 확인
- 에뮬레이터 크래시 → AVD RAM 4GB 확인

### 문서화 시
- 기술 선택 변경 시 `.planning/decisions/`에 새 ADR 추가
- 설치/설정 변경 시 `docs/setup.md` 업데이트

---

## 사용한 AI 도구

| 도구 | 용도 |
|------|------|
| Claude (claude.ai) | 기획, 코드 생성, 디버깅, 문서 작성 전반 |
| Claude Code | 파일 직접 편집, 터미널 작업, 발표자료 생성 |
