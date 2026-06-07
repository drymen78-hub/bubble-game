# 버블팝 그림책 — 현황 & 이어서 할 일 (최종 업데이트 2026-06-08)

> 다음에 이어서 작업할 때 **이 파일부터** 읽으면 됩니다.

## 🟢 현재 상태 — 웹 버전 라이브 완성
- **라이브**: https://drymen78-hub.github.io/bubble-game/ (GitHub Pages, repo public, `.nojekyll`)
- **개인정보처리방침**: https://drymen78-hub.github.io/bubble-game/privacy.html
- 폰 브라우저로 열어 "홈 화면에 추가"하면 앱처럼 전체화면 동작.
- SW network-first(HTML) → **푸시 후 새로고침하면 즉시 반영**. 현재 캐시 `bubblepop-v9`.
- ⚠️ GitHub **Settings의 "Change visibility" 누르지 말 것**(토글이라 private로 돌아가 Pages 꺼짐).

## ✅ 지금까지 반영된 개선 (요약)
- **손맛**: 버블 팝 햅틱(진동) + 물방울 '뽁/톡' 사운드(팝마다 음높이 변주) + pointerdown 즉시반응·멀티터치.
- **그림**: 시스템 이모지 → **OpenMoji SVG 162개** 번들(`img/`, 일관된 일러스트, CC BY-SA 4.0 표기).
- **첫 화면 재설계**: 히어로 + [난이도][주제] + 큰 PLAY + '더보기'(이름·언어·소리·기타 접기). 100dvh+safe-area로 한 화면 맞춤.
- **나이→난이도 3단계**(쉬움/보통/어려움, 기본 '보통'). 숫자 나이 입력 제거.
- **재방문성**: 지난 설정(난이도·주제·언어·소리·BGM) 기억.
- **학습/입소문**: '내 단어장'(맞춘 단어 수집·다시듣기), 청중별 '자랑하기'.
- **돌아가기**: 결과/타임아웃 화면 '🏠 다른 단어 고르기' + HUD 🏠.
- **더블탭 확대 방지**: touch-action(연타 시 화면 확대 X).
- **TTS**: 원래 동작 유지(브라우저 기본 음성으로 단어 발음). ⚠ 아래 '알려진 한계' 참고.

## 🔴 플레이스토어(TWA) 출시에 남은 일 — 박철순만 가능
웹은 끝. **앱(스토어) 출시**하려면 아래만 하면 됨:
1. **Play Console에 AAB 업로드** — `twa-build/app-release-bundle.aab` (비공개 테스트 트랙).
2. **assetlinks 지문 채우기**:
   - 업로드 키: `keytool -list -v -keystore twa-build\bubblepop-release.keystore -alias bubblepop` → `SHA256:` 값
   - Play 앱서명 키: 업로드 후 Play Console → 설정 → 앱 무결성의 SHA-256
   - 둘 다 → **루트 repo `drymen78-hub.github.io`** 의 `/.well-known/assetlinks.json` 에 배치
     (도메인 루트에서 검증됨. 이 repo의 `.well-known/assetlinks.json`은 내용 템플릿. 루트 repo는 아직 없음 → 새로 만들어야 함. 클로드가 도와줄 수 있음)
3. **Play 정책 폼**(어린이=가족 정책): 타겟연령(만13세 미만)·콘텐츠등급·데이터안전(수집없음·기기내저장)·방침URL(`/privacy.html`).
4. **비공개 테스트 20명 · 14일 연속** → 프로덕션 신청.

## ⚠️ 알려진 한계 / 다음에 고려할 것
- **TTS 발음은 기기 음성에 의존**: 해당 언어 음성이 없는 기기는 무음/부정확(예: 영어 음성 없는 Windows). 기기 설정에서 음성 추가하면 해결. **근본 해결 = 단어별 발음 오디오 사전 녹음/생성해 번들**(언어학습앱 정석, 미착수 — 영어부터 추천).
- 폰트 로컬 번들 미적용(Jua 97개 서브셋 ~1-2MB라 보류). Google Fonts 사용은 privacy에 고지됨.
- 세션 종료 구조 없음(현재 15단어 무한 루프), 간격반복(SRS) 학습 미적용 — 향후 개선 후보.
- `twa-build/`는 .gitignore 처리됨(서명키 보호). 네이티브/host 변경 시에만 AAB 재빌드 필요(웹 개선은 재빌드 불필요 — TWA가 라이브 URL 로드).

## 작업 환경 메모
- 로컬: `C:\bubble-game` / repo: github.com/drymen78-hub/bubble-game (public)
- 단일 파일 `index.html`(인라인 JS) + `sw.js` + `img/`(OpenMoji) + `manifest.json` + `privacy.html`
- 검증: Edge headless를 playwright-core로 구동(임시폴더). 푸시→Pages 자동빌드(~15초)→새로고침.
