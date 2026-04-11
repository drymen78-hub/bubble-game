# 버블팝 그림책 — TWA Android APK 빌드 가이드

> **TWA(Trusted Web Activity)** 란?  
> PWA를 그대로 Android 앱으로 감싸는 공식 방식입니다.  
> Chrome 팀이 만든 **Bubblewrap CLI** 를 사용합니다.

---

## 전체 흐름

```
사전 요구사항 설치
      ↓
GitHub Pages 에 PWA 배포
      ↓
Bubblewrap 프로젝트 초기화
      ↓
Keystore 생성 (서명 키)
      ↓
assetlinks.json 설정 및 배포
      ↓
Debug APK 테스트
      ↓
Release AAB 빌드
      ↓
Play Store 업로드
```

---

## ✅ 준비물 체크리스트

| 항목 | 버전 | 확인 명령 |
|------|------|----------|
| Node.js | 18 LTS 이상 | `node --version` |
| Java JDK | 17 (Temurin 권장) | `java -version` |
| Android SDK | API 34 포함 | Android Studio 설치 시 자동 |
| Bubblewrap CLI | 최신 | `bubblewrap --version` |
| GitHub 계정 | - | github.com |

> **빠른 환경 설정:** `setup-twa.bat` 더블클릭으로 자동 확인/설치

---

## STEP 1 — 사전 요구사항 설치

### 1-1. Java JDK 17 설치 (필수)

1. https://adoptium.net/temurin/releases/?version=17 접속
2. **Windows x64 `.msi`** 다운로드 및 설치
3. 설치 시 **"Set JAVA_HOME variable"** 옵션 ✅ 체크
4. 설치 완료 후 새 터미널에서 확인:

```powershell
java -version
# openjdk version "17.x.x" ...
```

### 1-2. Android Studio 설치 (Android SDK 포함)

1. https://developer.android.com/studio 에서 다운로드
2. 설치 후 **SDK Manager** 열기 (Tools → SDK Manager)
3. 다음 항목 설치:
   - Android SDK Platform **34** (Android 14)
   - Android SDK Platform **21** (Android 5.0 — 최소 버전)
   - Android SDK Build-Tools **34.x**
   - Android SDK Command-line Tools (latest)

4. 환경 변수 설정 (Windows):

```powershell
# 시스템 환경 변수 > 새로 만들기
변수명: ANDROID_HOME
변수값: C:\Users\[사용자명]\AppData\Local\Android\Sdk

# Path에 추가:
%ANDROID_HOME%\platform-tools
%ANDROID_HOME%\cmdline-tools\latest\bin
```

5. 설치 확인:

```powershell
adb --version
sdkmanager --version
```

### 1-3. Bubblewrap CLI 설치

```powershell
npm install -g @bubblewrap/cli
bubblewrap --version
```

---

## STEP 2 — GitHub Pages에 PWA 배포

TWA는 **공개 HTTPS URL** 이 반드시 필요합니다.

### 2-1. GitHub 리포지토리 생성

1. github.com에서 새 리포지토리 생성
   - 이름: `bubble-game`
   - Public ✅

### 2-2. 파일 업로드

리포지토리에 아래 파일들을 업로드:

```
bubble-game/
├── upgraded_index.html      → index.html 로 이름 변경 후 업로드
├── upgraded_manifest.json   → manifest.json 으로 이름 변경 후 업로드
├── upgraded_sw.js           → sw.js 로 이름 변경 후 업로드
├── android-chrome-192x192.png
├── android-chrome-512x512.png
└── .well-known/
    └── assetlinks.json      ← STEP 4 완료 후 업로드
```

### 2-3. GitHub Pages 활성화

1. 리포지토리 Settings → Pages
2. Source: **Deploy from a branch**
3. Branch: **main** / **(root)**
4. Save

배포 URL: `https://[사용자명].github.io/bubble-game/`

### 2-4. PWA 정상 동작 확인

배포 후 Chrome에서 URL 접속 → DevTools → Lighthouse 실행  
**PWA 카테고리** 항목이 모두 녹색이어야 합니다.

---

## STEP 3 — twa-manifest.json 수정

`twa-manifest.json` 파일에서 `YOUR_GITHUB_USERNAME` 을 실제 값으로 교체:

```json
{
  "host": "실제사용자명.github.io",
  "startUrl": "/bubble-game/",
  "fullScopeUrl": "https://실제사용자명.github.io/bubble-game/",
  "iconUrl": "https://실제사용자명.github.io/bubble-game/android-chrome-512x512.png",
  "webManifestUrl": "https://실제사용자명.github.io/bubble-game/manifest.json"
}
```

---

## STEP 4 — Keystore 생성 (서명 키) ⚠️ 중요

> **경고:** Keystore 파일과 비밀번호를 절대 잃어버리면 안 됩니다.  
> 분실 시 같은 앱으로 Play Store 업데이트가 영구적으로 불가능합니다.  
> 반드시 외부 저장장치에 백업하세요.

```powershell
# 프로젝트 폴더에서 실행
keytool -genkey -v ^
  -keystore bubblepop-release.keystore ^
  -alias bubblepop ^
  -keyalg RSA ^
  -keysize 2048 ^
  -validity 10000

# 입력 항목:
# 키 저장소 비밀번호: (기억할 수 있는 강력한 비밀번호)
# 이름 (CN): 개발자 이름 또는 회사명
# 조직 단위 (OU): (Enter 스킵 가능)
# 조직 (O): (Enter 스킵 가능)
# 도시 (L): Seoul
# 주/도 (ST): Seoul
# 국가 코드 (C): KR
```

### 4-1. SHA-256 지문 추출

```powershell
keytool -list -v ^
  -keystore bubblepop-release.keystore ^
  -alias bubblepop

# 출력에서 SHA256: 항목 복사
# 예: AB:CD:12:34:...
```

출력 예시:
```
Certificate fingerprints:
   SHA1: XX:XX:XX:...
   SHA256: AB:CD:12:34:56:78:9A:BC:DE:F0:...
```

---

## STEP 5 — assetlinks.json 설정

`.well-known/assetlinks.json` 파일을 수정:

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.bubblepop.picturebook",
      "sha256_cert_fingerprints": [
        "AB:CD:12:34:56:78:9A:BC:DE:F0:..."
      ]
    }
  }
]
```

> SHA-256 형식: 콜론(:)으로 구분된 대문자 16진수 (keytool 출력 그대로 사용)

수정 후 GitHub에 푸시:
```
https://[사용자명].github.io/bubble-game/.well-known/assetlinks.json
```
위 URL이 브라우저에서 JSON으로 보이는지 확인합니다.

### 5-1. 검증 (Google 공식 도구)

```
https://digitalassetlinks.googleapis.com/v1/statements:list
  ?source.web.site=https://[사용자명].github.io
  &relation=delegate_permission/common.handle_all_urls
```

응답에 `"complete": true` 가 있으면 성공입니다.

---

## STEP 6 — Bubblewrap 프로젝트 초기화

```powershell
# twa-build 폴더 생성 및 이동
mkdir twa-build
cd twa-build

# twa-manifest.json 으로 프로젝트 초기화
bubblewrap init --manifest ..\twa-manifest.json

# 질문 응답:
# Android SDK 경로: C:\Users\[사용자명]\AppData\Local\Android\Sdk
# JDK 경로: C:\Program Files\Eclipse Adoptium\jdk-17.x.x.x-hotspot
```

초기화 완료 후 생성된 파일들:
```
twa-build/
├── app/
│   ├── src/main/
│   │   ├── AndroidManifest.xml
│   │   └── res/
│   └── build.gradle
├── gradle/
├── build.gradle
└── gradlew.bat
```

---

## STEP 7 — Debug APK 빌드 (테스트용)

```powershell
# twa-build 폴더 안에서 실행
bubblewrap build

# 또는 직접 Gradle 사용
.\gradlew.bat assembleDebug
```

빌드 완료 후 APK 위치:
```
twa-build\app\build\outputs\apk\debug\app-debug.apk
```

### 7-1. 기기에 설치하여 테스트

```powershell
# USB 디버깅이 켜진 Android 기기 연결 후
adb install app\build\outputs\apk\debug\app-debug.apk
```

---

## STEP 8 — Release AAB 빌드 (Play Store용)

> Play Store는 APK 대신 **AAB (Android App Bundle)** 권장

```powershell
# twa-build 폴더 안에서 실행
bubblewrap build --skipPwaValidation

# 또는 직접 Gradle 사용
.\gradlew.bat bundleRelease
```

### 8-1. 서명된 Release AAB 생성

```powershell
.\gradlew.bat bundleRelease

# 서명 (jarsigner 또는 apksigner 사용)
jarsigner -verbose ^
  -sigalg SHA256withRSA ^
  -digestalg SHA-256 ^
  -keystore ..\bubblepop-release.keystore ^
  app\build\outputs\bundle\release\app-release.aab ^
  bubblepop
```

빌드 완료 파일:
```
twa-build\app\build\outputs\bundle\release\app-release.aab  ← Play Store 업로드용
twa-build\app\build\outputs\apk\release\app-release.apk     ← 직접 배포용
```

### 8-2. APK 서명 검증

```powershell
apksigner verify --verbose ^
  app\build\outputs\apk\release\app-release.apk

# 출력에 "Verified using v2 scheme: true" 확인
```

---

## STEP 9 — Play Store 업로드

### 9-1. Google Play Console 설정

1. https://play.google.com/console 접속
2. 앱 만들기 클릭
3. 기본 정보 입력:
   - 앱 이름: 버블팝 그림책
   - 기본 언어: 한국어
   - 앱 또는 게임: **게임**
   - 유료 또는 무료: **무료**

### 9-2. 어린이 앱 설정 (중요)

Play Console → 앱 콘텐츠:

| 항목 | 설정값 |
|------|--------|
| 타겟 연령 | **어린이 (만 5세 이하 포함)** |
| 광고 여부 | 광고 없음 |
| 개인정보처리방침 URL | GitHub Pages의 privacy 페이지 URL |

> ⚠️ 어린이 앱으로 설정하면 광고 SDK 사용이 금지됩니다.  
> 우리 앱은 광고가 없으므로 문제없습니다.

### 9-3. IARC 연령 등급 설문

앱 콘텐츠 → 연령 등급 → 설문 시작:
- 폭력: 없음
- 성적 콘텐츠: 없음
- 언어: 없음
- 도박: 없음
→ 예상 등급: **전체 이용가 (Everyone)**

### 9-4. 내부 테스트로 AAB 업로드

1. 테스트 → 내부 테스트 → 새 버전 만들기
2. `app-release.aab` 업로드
3. 버전 이름: `1.0.0`, 버전 코드: `1`
4. 내부 테스트 이메일로 APK 설치 및 TWA 동작 확인

### 9-5. 프로덕션 출시

내부 테스트 통과 후:
1. 프로덕션 → 새 버전 만들기
2. 검토 제출
3. 검토 기간: 보통 1~3일 (어린이 앱은 최대 7일)

---

## STEP 10 — 버전 업데이트 방법

앱을 수정한 후 업데이트 배포하는 흐름:

```
1. index.html 수정
2. GitHub에 푸시 (PWA 자동 업데이트)
3. twa-manifest.json 에서 appVersionCode +1
4. bubblewrap build 재실행
5. Play Store에 새 AAB 업로드
```

> PWA 콘텐츠(HTML/JS)만 바뀌는 경우 Service Worker가 자동 업데이트하므로  
> APK를 재빌드할 필요가 없습니다. 앱 구조(packageId 등) 변경 시만 재빌드하세요.

---

## 문제 해결 (Troubleshooting)

### ❌ "Digital Asset Links verification failed"

```
원인: assetlinks.json 의 SHA-256 지문이 keystore와 불일치
해결:
  1. keytool -list -v -keystore bubblepop-release.keystore 로 지문 재확인
  2. .well-known/assetlinks.json 업데이트 후 GitHub 푸시
  3. CDN 캐시 대기 (최대 10분)
  4. 검증 URL로 재확인
```

### ❌ "ANDROID_HOME not found"

```
해결 (PowerShell):
  $env:ANDROID_HOME = "C:\Users\[사용자명]\AppData\Local\Android\Sdk"
  $env:Path += ";$env:ANDROID_HOME\platform-tools"
  또는 시스템 환경 변수에 영구 등록
```

### ❌ "SDK location not found" (Gradle 빌드 오류)

```
해결: twa-build\local.properties 파일에 추가
  sdk.dir=C\:\\Users\\[사용자명]\\AppData\\Local\\Android\\Sdk
  (경로의 \ 는 \\ 로 이스케이프)
```

### ❌ "Keystore was tampered with or password was incorrect"

```
원인: 비밀번호 오입력
해결: keytool 명령 재실행 시 정확한 비밀번호 입력
     - Keystore 비밀번호 ≠ Key 비밀번호 (둘 다 같게 설정 권장)
```

### ❌ TWA 앱이 브라우저 URL 바를 숨기지 않음

```
원인: Digital Asset Links 미검증 상태
해결:
  1. assetlinks.json URL 직접 접근 확인
  2. SHA-256 지문 정확히 일치하는지 확인
  3. package_name이 twa-manifest.json 의 packageId와 동일한지 확인
```

### ❌ "minSdkVersion 21" 빌드 오류

```
해결: twa-build\app\build.gradle 에서
  minSdkVersion 21  ← 확인
  targetSdkVersion 34  ← 확인
```

---

## 참고 자료

| 리소스 | URL |
|--------|-----|
| Bubblewrap GitHub | https://github.com/GoogleChromeLabs/bubblewrap |
| TWA 공식 문서 | https://developer.chrome.com/docs/android/trusted-web-activity |
| Digital Asset Links | https://developers.google.com/digital-asset-links |
| Play Console | https://play.google.com/console |
| IARC 연령 등급 | https://www.globalratings.com |
| Lighthouse PWA 검사 | Chrome DevTools → Lighthouse → Progressive Web App |

---

## 파일 구조 요약

```
bubble-game/
├── upgraded_index.html        ← 배포 시 index.html 로 이름 변경
├── upgraded_manifest.json     ← 배포 시 manifest.json 으로 이름 변경
├── upgraded_sw.js             ← 배포 시 sw.js 로 이름 변경
├── android-chrome-192x192.png
├── android-chrome-512x512.png
├── upgraded_privacy.md        ← 웹에서 접근 가능한 URL로 호스팅 필요
│
├── twa-manifest.json          ← Bubblewrap 설정 (★ YOUR_GITHUB_USERNAME 수정)
├── bubblepop-release.keystore ← STEP 4 에서 생성 (⚠️ 절대 공개 금지)
│
├── .well-known/
│   └── assetlinks.json        ← STEP 5 에서 SHA-256 입력 후 배포
│
├── setup-twa.bat              ← 환경 설정 자동화 스크립트
├── BUILD_GUIDE.md             ← 이 파일
│
└── twa-build/                 ← bubblewrap init 후 생성되는 Android 프로젝트
    ├── app/
    ├── gradle/
    └── gradlew.bat
```

---

*빌드 문의: drymen78@gmail.com*
