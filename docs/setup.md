# 개발 환경 설정 가이드

처음 보는 사람도 이 문서를 따라하면 앱을 실행할 수 있습니다.

## 사전 요구사항

| 도구 | 버전 | 다운로드 |
|------|------|----------|
| Flutter | 3.x 이상 | https://flutter.dev/docs/get-started/install |
| Android Studio | 최신 | https://developer.android.com/studio |
| Git | 최신 | https://git-scm.com |
| VS Code (선택) | 최신 | https://code.visualstudio.com |

---

## 1단계 — 저장소 클론

```bash
git clone https://github.com/qkrwlsrb/place-archive.git
cd place-archive
```

---

## 2단계 — Flutter 패키지 설치

```bash
flutter pub get
```

---

## 3단계 — Firebase 프로젝트 설정

### 3-1. Firebase 프로젝트 생성

1. https://console.firebase.google.com 접속
2. 프로젝트 추가 → 이름 입력 → 생성
3. **Authentication** → 시작하기 → 이메일/비밀번호 사용 설정
4. **Firestore Database** → 데이터베이스 만들기 → 프로덕션 모드 → 서울(asia-northeast3)
5. **Storage** → 시작하기 (Blaze 플랜 필요)

### 3-2. FlutterFire CLI 설치

```bash
dart pub global activate flutterfire_cli
```

> Windows PATH 설정이 필요한 경우:
> ```powershell
> $env:PATH += ";C:\Users\<사용자명>\AppData\Local\Pub\Cache\bin"
> $env:PATH += ";C:\Users\<사용자명>\AppData\Roaming\npm"
> ```

### 3-3. Firebase 프로젝트 연결

```bash
firebase login
flutterfire configure --project=<firebase-project-id>
```

완료되면 `lib/firebase_options.dart` 파일이 자동 생성됩니다.

### 3-4. Firestore 보안 규칙 설정

Firebase Console → Firestore Database → 규칙 탭:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /capsules/{capsuleId} {
      allow create: if request.auth != null;
      allow read, update, delete: if request.auth != null
        && request.auth.uid == resource.data.userId;
    }
  }
}
```

### 3-5. Firestore 복합 인덱스 생성

Firebase Console → Firestore Database → 색인 → 복합 색인 추가:

| 컬렉션 | 필드 1 | 필드 2 |
|--------|--------|--------|
| capsules | userId (오름차순) | createdAt (내림차순) |
| capsules | isPublic (오름차순) | createdAt (내림차순) |

### 3-6. Storage 보안 규칙 설정

Firebase Console → Storage → 규칙 탭:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /capsules/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
    }
  }
}
```

---

## 4단계 — Google Maps API 설정

### 4-1. API 키 발급

1. https://console.cloud.google.com 접속
2. API 및 서비스 → 사용자 인증 정보 → API 키 만들기
3. Maps SDK for Android 활성화
4. 키 제한: Android 앱 → 패키지명 `com.example.place_archive` 추가

### 4-2. AndroidManifest.xml에 키 등록

`android/app/src/main/AndroidManifest.xml`의 `<application>` 태그 안에:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="여기에_API_키_입력"/>
```

---

## 5단계 — Android 에뮬레이터 설정

```bash
# 에뮬레이터 목록 확인
flutter emulators

# 에뮬레이터 실행
flutter emulators --launch <emulator-id>
```

> **권장 에뮬레이터:** Pixel 6, API 33, RAM 4GB 이상
>
> **Windows 한글 경로 주의:** 프로젝트 경로에 한글이 포함되면 빌드 오류 발생.
> 반드시 영어 경로에서 실행하세요. (예: `C:\project\place_archive`)

---

## 6단계 — 앱 실행

```bash
flutter run
```

---

## 7단계 — 빌드 확인

```bash
flutter doctor
```

모든 항목에 ✓ 표시가 뜨면 정상입니다.

---

## 문제 해결

| 증상 | 원인 | 해결 |
|------|------|------|
| `firebase_options.dart` 없음 | flutterfire configure 미실행 | 3-3단계 실행 |
| Firestore permission-denied | 보안 규칙 미설정 | 3-4단계 확인 |
| 지도 안 뜸 (빨간 화면) | Maps API 키 없음 | 4-2단계 확인 |
| 에뮬레이터 타임아웃 | RAM 부족 | RAM 4GB로 설정 |
| 한글 경로 빌드 오류 | 경로에 한글 포함 | 영어 경로로 이동 |
| GPS 안 잡힘 (에뮬레이터) | 가상 위치 미설정 | 에뮬레이터 ... → Location 탭에서 좌표 입력 |
