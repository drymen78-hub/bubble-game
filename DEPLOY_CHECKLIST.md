# 버블팝 그림책 — 배포 점검 & 남은 작업 (2026-06-08)

## ✅ 코드에서 이미 개선 완료 (이 커밋)
- `privacy.html` 신규 — Play용 **공개 렌더링 가능한** 개인정보처리방침(5개 언어). `.md`는 GitHub Pages에서 HTML로 안 보일 수 있어 HTML 버전 추가.
- `privacy.md` 개요 문구 수정 — "수집·**저장**·전송·공유 안 함" → "수집·전송·공유 안 함 + 진행정보는 기기 내 저장"으로 정정(3항과 모순 제거, 5개 언어 모두).
- `.well-known/assetlinks.json` — 플레이스홀더를 **2개 지문 슬롯**(Play 앱서명 키 + 업로드 키)으로 정비.

## 🔴 반드시 사용자가 해야 하는 것 (코드로 불가)

### 1. 호스팅 살리기 — 현재 `https://drymen78-hub.github.io/bubble-game/` 가 404
원인: **repo가 private** → 무료 GitHub Pages는 private repo를 게시하지 않음.
선택지(택1):
- **(A) repo를 public 으로 전환** + Settings → Pages → Source: `main / (root)` 활성화. ⚠️ public 전환은 **되돌리기 어려움**(전체 코드·커밋 이력 공개). keystore는 커밋 안 돼 있어 안전하나, 공개 의사 확인 필요.
- **(B) GitHub Pro** 사용 시 private 유지한 채 Pages 가능.
- **(C) Cloudflare Workers** 로 호스팅(다른 대시보드들처럼). 단 TWA host가 바뀌므로 **AAB 재빌드 필요**.

### 2. Digital Asset Links 위치 문제 (중요)
안드로이드는 `https://drymen78-hub.github.io/.well-known/assetlinks.json` (**도메인 루트**)에서만 검증함.
그런데 이 앱은 프로젝트 페이지(`/bubble-game/` 하위)라, 이 repo의 `.well-known/`은 검증 위치가 **아님**.
→ **루트 Pages repo(`drymen78-hub.github.io` 이름)** 를 새로 만들어(public) 그 안에 `.well-known/assetlinks.json` 을 두어야 함.
   (이 repo의 `.well-known/assetlinks.json` 은 내용 템플릿으로만 사용 — 복사해서 루트 repo에 배치.)

### 3. SHA-256 지문 채우기 (`assetlinks.json`)
- **업로드 키 지문**: 아래 명령으로 추출(비밀번호는 본인이 STEP 4에서 정한 것):
  ```
  keytool -list -v -keystore twa-build\bubblepop-release.keystore -alias bubblepop
  ```
  출력의 `SHA256:` 값 → `UPLOAD_KEY_SHA256_HERE` 자리에.
- **Play 앱서명 키 지문**: AAB를 Play Console에 업로드 후 **설정 → 앱 무결성(App signing)** 화면의 SHA-256 → `PLAY_APP_SIGNING_SHA256_HERE` 자리에.
  (Play App Signing이 출시본을 재서명하므로 이 지문이 **반드시** 들어가야 함. 둘 다 넣는 게 안전.)

### 4. Play Console 정책 폼 (어린이 앱이라 필수)
- **타겟 연령·콘텐츠**: 만 13세 미만 대상 선언 → Google Play **가족(Families) 정책** 적용.
- **콘텐츠 등급 설문** 작성.
- **데이터 안전(Data safety)**: 실제 동작과 일치하게 — "데이터 수집 없음, 기기 내 로컬 저장만, 외부 전송 없음".
- **개인정보처리방침 URL**: `https://drymen78-hub.github.io/bubble-game/privacy.html` (호스팅 살린 뒤).

## 🟡 권장(블로커 아님)
- **Google Fonts 로컬 번들**: 미적용. 이유 — Jua(한국어) 폰트가 **97개 woff2 서브셋(~1–2MB)** 으로 쪼개져 있어 수작업 번들은 앱을 크게 비대화시킴(단순 키즈 게임에 과함). privacy에 Google Fonts 사용을 이미 고지함. 엄격한 무(無)-3rd-party 통신을 원하면 빌드 도구로 별도 self-host 권장.
- `appVersionCode`: 루트 `twa-manifest.json`(1) vs `twa-build/app/build.gradle`(2) 불일치 — 업로드마다 versionCode 증가만 지키면 무방.

## 순서 요약
호스팅 살리기(1) → AAB Play 업로드(비공개 트랙) → 앱서명 지문 확보(3) → 루트 repo에 assetlinks 배치(2·3) → 전체화면 동작 확인 → 정책 폼(4) → 테스터 20명·14일.
