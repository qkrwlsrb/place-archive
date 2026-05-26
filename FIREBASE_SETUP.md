# Firebase 셋업 가이드

## 1. 패키지 설치

```bash
flutter pub get
```

## 2. FlutterFire CLI 설치 (처음 한 번만)

```bash
dart pub global activate flutterfire_cli
```

PATH에 없으면 아래 추가 (PowerShell):
```powershell
$env:PATH += ";$env:APPDATA\Pub\Cache\bin"
```

## 3. Firebase 프로젝트 생성

1. https://console.firebase.google.com 접속
2. 프로젝트 추가 → 이름: `place-archive`
3. Google Analytics: 사용 안 함으로 체크 해제 후 생성

## 4. Firebase Auth 활성화

1. 좌측 메뉴 → Authentication → 시작하기
2. Sign-in method 탭 → 이메일/비밀번호 → 사용 설정

## 5. Firestore 데이터베이스 생성

1. 좌측 메뉴 → Firestore Database → 데이터베이스 만들기
2. 테스트 모드로 시작 (30일 후 규칙 수정 필요)
3. 위치: asia-northeast3 (서울)

## 6. FlutterFire Configure 실행

프로젝트 루트(`C:\project\place_archive`)에서:

```bash
flutterfire configure
```

- Firebase 프로젝트 선택: place-archive
- 플랫폼 선택: android, ios 체크 (스페이스바로 선택, 엔터 확인)
- `lib/firebase_options.dart` 자동 생성됨

## 7. Android 설정 확인

`android/app/build.gradle`에 아래가 있는지 확인:
```gradle
apply plugin: 'com.google.gms.google-services'
```

`android/build.gradle`에:
```gradle
classpath 'com.google.gms:google-services:4.4.0'
```

flutterfire configure가 자동으로 추가해주지만, 없으면 수동 추가.

## 8. 빌드 및 실행

```bash
flutter run
```

## Firestore 보안 규칙 (개발 완료 후 적용)

Firebase Console → Firestore → 규칙 탭:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /capsules/{capsuleId} {
      allow read, write: if request.auth != null
                         && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }
  }
}
```
