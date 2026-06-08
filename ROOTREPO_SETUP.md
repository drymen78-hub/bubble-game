# 루트 repo + assetlinks 설정 가이드 (TWA 주소창 제거)

> TWA 앱에서 **주소창(URL bar)이 안 뜨게** 하려면, 도메인 **루트**에
> Digital Asset Links 파일이 있어야 합니다:
> `https://drymen78-hub.github.io/.well-known/assetlinks.json`
>
> 프로젝트 페이지(`/bubble-game/`)가 아니라 **도메인 루트**에서 검증되므로,
> 사용자 페이지 repo **`drymen78-hub.github.io`** 가 필요합니다(아직 없음).
>
> 준비된 스캐폴드: `tools/rootrepo-scaffold/` (그대로 푸시하면 됨, 지문만 채우기).

---

## 0. 왜 지문을 지금 못 채우나
assetlinks 의 `sha256_cert_fingerprints` 2개는 **박철순만** 얻을 수 있습니다:
- **업로드 키 지문**: 로컬 keystore에서 추출(비밀번호 필요)
- **Play 앱서명 키 지문**: AAB 업로드 **후** Play Console에서 발급
→ 그래서 클로드가 미리 채워둘 수 없고, 스캐폴드에 자리표시자(`..._HERE`)만 넣어둠.

## 1. 두 지문 얻기
**(A) 업로드 키 지문** — 로컬에서:
```powershell
keytool -list -v -keystore twa-build\bubblepop-release.keystore -alias bubblepop
```
출력의 `SHA256:` 값(콜론 포함 16진수)을 복사 → `UPLOAD_KEY_SHA256_HERE` 자리에.

**(B) Play 앱서명 키 지문** — AAB 업로드 후:
Play Console → (앱) → **설정 → 앱 무결성(앱 서명)** → "앱 서명 키 인증서"의 **SHA-256** 복사
→ `PLAY_APP_SIGNING_SHA256_HERE` 자리에.

## 2. 스캐폴드에 지문 채우기
편집: `tools/rootrepo-scaffold/.well-known/assetlinks.json`
```json
"sha256_cert_fingerprints": [
  "AA:BB:CC:...:99",   // ← Play 앱서명 키 SHA-256
  "11:22:33:...:FF"    // ← 업로드 키 SHA-256
]
```
(둘 다 넣으면 업로드 키/Play 서명 키 어느 쪽으로 서명돼도 검증 통과)

## 3. 루트 repo 생성 + 푸시 (gh CLI, 이미 drymen78-hub 로그인됨)
```powershell
# 스캐폴드 폴더로 이동
cd C:\bubble-game\tools\rootrepo-scaffold

git init -b main
git add -A
git commit -m "init: 루트 페이지 + assetlinks"

# 사용자 페이지 repo는 반드시 이름이 <계정>.github.io 여야 함
gh repo create drymen78-hub.github.io --public --source=. --remote=origin --push
```
> ⚠️ 이 repo는 `https://drymen78-hub.github.io/` **루트 사이트**가 됩니다.
> 기존 bubble-game( `/bubble-game/` )은 그대로 유지되고, 루트에 랜딩이 추가될 뿐입니다.

## 4. GitHub Pages 켜기
```powershell
gh api -X POST repos/drymen78-hub/drymen78-hub.github.io/pages -f "source[branch]=main" -f "source[path]=/" 2>$null
# 또는 웹: repo Settings → Pages → Source: Deploy from a branch → main / (root)
```
`.well-known` 폴더가 무시되지 않도록 `.nojekyll` 도 추가 권장(스캐폴드에 포함시키려면 아래 5번).

## 5. 검증
배포 후(약 1분):
```powershell
curl https://drymen78-hub.github.io/.well-known/assetlinks.json
```
- 지문이 담긴 JSON이 그대로 보이면 OK.
- 구글 검증 도구:
  `https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://drymen78-hub.github.io&relation=delegate_permission/common.handle_all_urls`
- 최종 확인: 폰에서 비공개 테스트 앱 설치 후 실행 → **주소창이 안 뜨면 성공**.

## 6. 체크리스트
- [ ] 업로드 키 SHA-256 추출 → assetlinks에 기입
- [ ] AAB 업로드 후 Play 앱서명 SHA-256 → assetlinks에 기입
- [ ] `drymen78-hub.github.io` repo 생성 + 푸시
- [ ] Pages 활성화 + `.nojekyll`
- [ ] `/.well-known/assetlinks.json` 200 확인
- [ ] 폰 설치 테스트 → 주소창 사라짐 확인

---
### 참고: `.nojekyll` 같이 넣기
Jekyll이 `.well-known`(점 폴더)을 무시할 수 있으니 루트에 빈 `.nojekyll` 파일을 두면 안전합니다:
```powershell
New-Item -ItemType File C:\bubble-game\tools\rootrepo-scaffold\.nojekyll
```
