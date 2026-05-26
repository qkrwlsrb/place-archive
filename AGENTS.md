# AGENTS.md — AI Agent 활용 가이드

이 문서는 이 프로젝트에서 AI Agent를 어떻게 활용했는지 기록합니다.

## 사용한 AI Agent

| 도구 | 용도 |
|------|------|
| Claude (claude.ai) | 기획, 코드 생성, 디버깅, 문서 작성 전반 |

## 주요 활용 패턴

### 1. 기획 단계
- 앱 주제 아이디어 도출 (20대 트렌드 기반)
- MoSCoW 요구사항 분류
- WBS 및 6주 일정 자동 생성

### 2. 설계 단계
- 레이어드 아키텍처 디렉토리 구조 생성
- Mermaid 다이어그램 작성
- ADR(Architecture Decision Record) 작성

### 3. 구현 단계
- Flutter 코드 초안 생성
- 빌드 오류 원인 분석 및 해결
- pubspec.yaml 의존성 관리

### 4. 문서화
- docs/setup.md, docs/architecture.md 자동 생성
- README 작성

## AI가 만든 것 내가 설명하는 방법

> AI가 만들었더라도 반드시 직접 설명할 수 있어야 한다.

각 코드 파일 상단에 레이어 설명 주석 작성:
- `// [Presentation Layer] — 화면 렌더링 담당`
- `// [Application Layer] — 상태 관리 담당`
- `// [Domain Layer] — 비즈니스 규칙 담당`
- `// [Data Layer] — API/DB 호출 담당`

## 삽질 기록 (배운 것)

| 문제 | 원인 | 해결 |
|------|------|------|
| pubspec.yaml 파싱 오류 | Git 충돌 마커 잔존 | 파일 직접 덮어쓰기 |
| Windows 빌드 실패 | 경로에 한글(징규) 포함 | 영어 경로로 프로젝트 이동 |
| Firebase Windows 빌드 실패 | C++ SDK 요구 | MVP 단계에서 Firebase 제거 후 나중에 추가 |
| 에뮬레이터 offline | AVD 경로 한글 | ANDROID_AVD_HOME 환경변수 설정 |
