@echo off
chcp 65001 > /dev/null
echo.
echo ====================================================
echo      버블팝 그림책 - TWA 빌드 환경 설정 도우미
echo ====================================================
echo.

:: 1. Node.js 확인
echo [1/5] Node.js 확인 중...
node --version > /dev/null 2>&1
if %errorlevel% neq 0 (
    echo  X  Node.js가 없습니다.
    echo     https://nodejs.org 에서 LTS 버전을 설치하세요.
    pause ^& exit /b 1
) else (
    for /f %%i in ('node --version') do echo  OK  Node.js %%i
)

:: 2. Java JDK 확인
echo.
echo [2/5] Java JDK 확인 중...
java -version > /dev/null 2>&1
if %errorlevel% neq 0 (
    echo  X  Java JDK가 없습니다.
    echo     https://adoptium.net 에서 JDK 17 (Temurin) 을 설치하세요.
    echo     설치 후 이 스크립트를 다시 실행하세요.
    echo.
    set /p OPEN=지금 다운로드 페이지를 여시겠습니까? (Y/N): 
    if /i "%OPEN%"=="Y" start https://adoptium.net/temurin/releases/?version=17
    pause ^& exit /b 1
) else (
    for /f "tokens=* delims=" %%i in ('java -version 2^>^&1 ^| findstr version') do echo  OK  %%i
)

:: 3. Android SDK 확인
echo.
echo [3/5] Android SDK 확인 중...
if defined ANDROID_HOME (
    echo  OK  ANDROID_HOME = %ANDROID_HOME%
) else if defined ANDROID_SDK_ROOT (
    echo  OK  ANDROID_SDK_ROOT = %ANDROID_SDK_ROOT%
) else (
    echo  X  Android SDK를 찾을 수 없습니다.
    echo     Android Studio를 설치하거나 ANDROID_HOME 환경 변수를 설정하세요.
    echo     설치 경로 예: C:\Users\사용자명\AppData\Local\Android\Sdk
    echo.
    set /p OPEN=Android Studio 다운로드 페이지를 여시겠습니까? (Y/N): 
    if /i "%OPEN%"=="Y" start https://developer.android.com/studio
    pause ^& exit /b 1
)

:: 4. Bubblewrap CLI 설치
echo.
echo [4/5] Bubblewrap CLI 설치 중...
bubblewrap --version > /dev/null 2>&1
if %errorlevel% neq 0 (
    echo     Bubblewrap를 설치합니다...
    npm install -g @bubblewrap/cli
    if %errorlevel% neq 0 (
        echo  X  Bubblewrap 설치 실패. npm 권한을 확인하세요.
        pause ^& exit /b 1
    )
    echo  OK  Bubblewrap CLI 설치 완료
) else (
    for /f %%i in ('bubblewrap --version') do echo  OK  Bubblewrap %%i (이미 설치됨)
)

:: 5. 빌드 폴더 생성
echo.
echo [5/5] 빌드 폴더 구성 중...
if not exist "twa-build" mkdir twa-build
echo  OK  twa-build\ 폴더 생성

:: 완료
echo.
echo ====================================================
echo              환경 설정 완료!
echo ====================================================
echo  다음 단계: BUILD_GUIDE.md 를 참고하세요.
echo.
echo  빠른 시작:
echo    1. twa-manifest.json 에서 YOUR_GITHUB_USERNAME
echo       을 실제 GitHub 사용자명으로 교체
echo    2. cd twa-build
echo    3. bubblewrap init --manifest ../twa-manifest
echo    4. bubblewrap build
echo ====================================================
echo.
pause