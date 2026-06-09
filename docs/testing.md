# 테스트 가이드

## 테스트 명령

```bash
# 전체 테스트 실행
flutter test

# 커버리지 포함
flutter test --coverage

# 특정 파일 테스트
flutter test test/unit/capsule_viewmodel_test.dart
```

## 테스트 구조

```
test/
├── unit/
│   ├── capsule_viewmodel_test.dart   # CapsuleViewModel 단위 테스트
│   └── auth_viewmodel_test.dart      # AuthViewModel 단위 테스트
└── widget/
    ├── login_screen_test.dart        # 로그인 화면 위젯 테스트
    └── capsule_card_test.dart        # 캡슐 카드 위젯 테스트
```

## 단위 테스트 (Unit Test)

ViewModel 로직을 Firebase 없이 Mock 객체로 테스트합니다.

### CapsuleViewModel 테스트 항목

| 테스트 | 설명 |
|--------|------|
| 캡슐 생성 | createCapsule 호출 시 repository 호출 확인 |
| 캡슐 삭제 | deleteCapsule 호출 시 Firestore + Storage 삭제 확인 |
| 검색 필터링 | 키워드로 메모 필터링 정확도 확인 |
| 로딩 상태 | isLoading 상태 변화 확인 |

### AuthViewModel 테스트 항목

| 테스트 | 설명 |
|--------|------|
| 로그인 성공 | status → authenticated 변경 확인 |
| 로그인 실패 | 에러 메시지 한국어 매핑 확인 |
| 로그아웃 | status → unauthenticated 변경 확인 |

## 통합 테스트 (Integration Test)

실제 Firebase Emulator를 연결하여 데이터 흐름 전체를 검증합니다.

```bash
# Firebase Emulator 실행
firebase emulators:start

# 통합 테스트 실행
flutter test integration_test/
```

### 통합 테스트 시나리오

1. 회원가입 → 로그인 → 캡슐 생성 → 목록 확인 → 삭제
2. 공개 캡슐 → 피드 노출 확인
3. GPS 위치 수집 → 캡슐 저장 → 마커 표시

## 수동 테스트 체크리스트

### 기능 테스트

- [ ] 이메일/비밀번호 회원가입
- [ ] 로그인 / 로그아웃
- [ ] 캡슐 생성 (메모 + GPS)
- [ ] 캡슐 수정
- [ ] 캡슐 삭제
- [ ] 공개/비공개 전환
- [ ] 검색 기능
- [ ] 피드 조회
- [ ] 프로필 통계
- [ ] 환경설정 (알림 토글, 비밀번호 재설정)

### 엣지 케이스

- [ ] 네트워크 없을 때 동작
- [ ] GPS 권한 거부 시 폴백
- [ ] 빈 메모 저장 시도
- [ ] 로그아웃 후 재로그인
