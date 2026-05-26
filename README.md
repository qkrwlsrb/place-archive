# 장소 기억 아카이브 (Place Memory Archive)

> 특정 장소에 사진·메모를 캡슐처럼 남기고, 그 장소를 다시 방문하면 기록이 열리는 감성 위치 기반 타임캡슐 앱

---

## 한 줄 가치 제안

"장소가 곧 일기장이 되는 세상. 걸어다니면서 과거의 나를 만나는 경험."

---

## 빠른 시작 (Quick Start)

> 이 한 줄로 실행 가능해야 합니다 (세션 3 요구사항)

```bash
git clone https://github.com/qkrwlsrb/place-archive.git && cd place-archive && flutter pub get && flutter run
```

자세한 설정은 [docs/setup.md](docs/setup.md) 참고

---

## 기술 스택

| 영역 | 기술 | 선택 이유 |
|------|------|-----------|
| 플랫폼 | Flutter 3.x | iOS + Android 동시 지원, Dart 학습 용이 |
| 상태관리 | Provider | Flutter 공식 권장, ViewModel 패턴 연결 |
| 백엔드 | Firebase (Firestore + Auth + Storage) | 서버 없이 인증·DB·이미지 저장 가능 |
| 지도 | Google Maps Flutter | 위치 기반 핀 표시 |
| 위치 | geolocator + geofencing | GPS 수집 및 재방문 감지 |

---

## 아키텍처

레이어드 아키텍처 (Layered Architecture) 적용

```
Presentation  →  Application  →  Domain  ←  Data
(화면/UI)        (상태관리)       (비즈니스규칙)  (API/DB)
```

자세한 내용은 [docs/architecture.md](docs/architecture.md) 참고

### 디렉토리 구조

```
lib/
├── main.dart
├── app.dart
├── presentation/
│   ├── screens/       # 화면
│   ├── widgets/       # 재사용 위젯
│   └── theme/         # 색상, 폰트
├── application/
│   ├── view_models/   # 상태 관리
│   └── use_cases/     # 비즈니스 흐름
├── domain/
│   ├── entities/      # 데이터 모델
│   └── services/      # 핵심 규칙
└── data/
    ├── repositories/  # 데이터 접근
    ├── api/           # Firebase 호출
    └── local/         # 로컬 캐시
```

---

## 핵심 기능 (Must)

| # | 기능 | 상태 |
|---|------|------|
| M1 | Google / Apple 소셜 로그인 | 🔲 개발 예정 |
| M2 | 현재 위치 캡슐 생성 (사진 + 메모) | 🔲 개발 예정 |
| M3 | 지도 위 캡슐 핀 시각화 | 🔲 개발 예정 |
| M4 | 재방문 감지 알림 | 🔲 개발 예정 |
| M5 | 공개 / 비공개 설정 | 🔲 개발 예정 |

---

## 의사결정 기록 (ADR)

| ADR | 결정 | 문서 |
|-----|------|------|
| ADR-0001 | Flutter 선택 | [링크](.planning/decisions/ADR-0001-platform.md) |
| ADR-0002 | Provider 상태관리 선택 | [링크](.planning/decisions/ADR-0002-state-management.md) |
| ADR-0003 | Firebase 백엔드 선택 | [링크](.planning/decisions/ADR-0003-backend.md) |

---

## 문서

| 문서 | 설명 |
|------|------|
| [docs/setup.md](docs/setup.md) | 개발 환경 설정 (zero → run) |
| [docs/architecture.md](docs/architecture.md) | 아키텍처 다이어그램 및 레이어 설명 |
| [.planning/00-vision.md](.planning/00-vision.md) | 비전 & 목표 |
| [.planning/01-requirements.md](.planning/01-requirements.md) | 요구사항 MoSCoW |
| [.planning/02-wbs.md](.planning/02-wbs.md) | WBS |
| [.planning/04-schedule.md](.planning/04-schedule.md) | 6주 일정 |
| [AGENTS.md](AGENTS.md) | AI Agent 활용 기록 |
| [BONUS.md](BONUS.md) | 가산점 트래킹 |

---

## 개발 환경

| 도구 | 버전 |
|------|------|
| Flutter | 3.16.x 이상 |
| Dart | 3.0.x 이상 |
| Android Studio | 2023.x |
| JDK | 17 |

---

## AI Agent 활용

이 프로젝트는 **Claude (claude.ai)** 를 AI Agent로 활용하여 기획·설계·코드·문서를 생성했습니다.

- 기획: 앱 주제 선정, MoSCoW 요구사항, WBS, 일정
- 설계: 아키텍처 다이어그램, ADR, 디렉토리 구조
- 구현: Flutter 코드 초안, 빌드 오류 디버깅
- 문서: setup.md, architecture.md, README

> AI가 만들었더라도 모든 내용을 직접 이해하고 설명할 수 있습니다.

---

## 라이선스

MIT
