# 빌드 & 배포 가이드

## 빌드 종류

| 종류 | 용도 | 명령어 |
|------|------|--------|
| debug | 개발 중 테스트 | `flutter run` |
| release | 배포용 | `flutter build apk --release` |
| profile | 성능 측정 | `flutter run --profile` |

## Android APK 빌드

```bash
# 릴리스 APK 빌드
flutter build apk --release

# 산출물 위치
build/app/outputs/flutter-apk/app-release.apk
```

## 환경별 설정

| 환경 | Firebase 프로젝트 | 용도 |
|------|-------------------|------|
| dev | place-c46c0 (현재) | 개발 및 테스트 |
| prod | 별도 구성 예정 | 실배포 |

## 버전 관리 (SemVer)

`pubspec.yaml`의 `version` 필드 관리:

```
version: 1.0.0+1
         │ │ │ └─ 빌드 번호 (스토어용)
         │ │ └─── patch (버그 수정)
         │ └───── minor (기능 추가)
         └─────── major (호환성 변경)
```

## 서명 (Release 빌드)

현재 debug keystore로 서명 중. 실제 배포 시:

1. keystore 생성
```bash
keytool -genkey -v -keystore release.jks -alias release -keyalg RSA -keysize 2048 -validity 10000
```

2. `android/key.properties` 생성 (gitignore에 포함)
```
storePassword=<비밀번호>
keyPassword=<비밀번호>
keyAlias=release
storeFile=../release.jks
```

3. `android/app/build.gradle.kts`에 서명 설정 추가

> ⚠️ keystore 파일과 key.properties는 절대 git에 커밋하지 않음

## 배포 채널

| 채널 | 방법 |
|------|------|
| 직접 설치 (현재) | APK 파일 전달 → 사이드로드 |
| Firebase App Distribution | 테스터 그룹에 배포 |
| Google Play Internal Testing | Play Console 업로드 |

## 롤백

이전 버전 태그로 체크아웃 후 재빌드:

```bash
git checkout v1.0.0
flutter build apk --release
```
