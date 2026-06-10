# 장소 기억 아카이브

> GPS로 현재 위치를 기록하며 그 장소의 기억을 사진과 메모로 남기는 위치 기반 타임캡슐 앱

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-orange)](https://firebase.google.com)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

## 데모

> 앱 실행 → 로그인 → 기억 남기기 → 지도에서 마커 확인 → 상세 조회

## 주요 기능

- 📍 **위치 기반 캡슐** — GPS로 현재 위치를 자동 기록하며 메모 + 사진 저장
- 🗺️ **지도 시각화** — Google Maps에 저장된 기억을 마커로 표시, 탭하면 상세 조회
- 🌍 **공개 피드** — 다른 사용자의 공개 기억 탐색
- 🔍 **검색** — 메모 내용으로 기억 검색 + 하이라이트
- 🔔 **Geofencing 알림** — 저장된 캡슐 100m 이내 진입 시 알림
- ✏️ **CRUD** — 기억 생성 / 조회 / 수정 / 삭제
- 👤 **프로필 & 통계** — 내 기억 현황, 환경설정

## 기술 스택

| 영역 | 기술 |
|------|------|
| 프레임워크 | Flutter 3.x (iOS + Android) |
| 상태관리 | Provider |
| 인증 | Firebase Auth |
| 데이터베이스 | Cloud Firestore |
| 스토리지 | Firebase Storage |
| 지도 | Google Maps Flutter |
| 위치 | Geolocator |
| 알림 | flutter_local_notifications |
| 폰트 | Google Fonts (Gaegu, Noto Sans KR) |

## 아키텍처

```
lib/
├── presentation/   # UI 화면 및 위젯
├── application/    # ViewModel (비즈니스 로직)
├── domain/         # Entity, Service (핵심 규칙)
└── data/           # Repository (Firebase 연동)
```

자세한 내용 → [docs/architecture.md](docs/architecture.md)

## 빠른 시작

```bash
git clone https://github.com/qkrwlsrb/place-archive.git
cd place-archive
flutter pub get
flutter run
```

자세한 환경 설정 → [docs/setup.md](docs/setup.md)

## 빌드 / 배포

```bash
# 릴리스 APK
flutter build apk --release
```

자세한 내용 → [docs/deploy.md](docs/deploy.md)

## 테스트

```bash
flutter test
```

자세한 내용 → [docs/testing.md](docs/testing.md)

## 프로젝트 구조

```
.planning/
├── 00-vision.md
├── 01-requirements.md
├── 02-wbs.md
├── 04-schedule.md
└── decisions/
    ├── ADR-0001-platform.md
    ├── ADR-0002-state-management.md
    ├── ADR-0003-backend.md
    ├── ADR-0004-maps.md
    ├── ADR-0005-gps.md
    └── ADR-0006-ui-design.md
docs/
├── setup.md
├── architecture.md
├── deploy.md
└── testing.md
lib/
├── presentation/
├── application/
├── domain/
└── data/
```

## 의사결정 로그

`.planning/decisions/` — ADR-0001 ~ ADR-0006 참고

## 라이선스

MIT

## 만든 사람

박진규 · [GitHub @qkrwlsrb](https://github.com/qkrwlsrb)
