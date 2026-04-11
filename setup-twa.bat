@echo off
chcp 65001 > /dev/null

:: ── 관리자 권한 자동 획득 ──────────────────────────────────
net session >/dev/null 2>&1
if %errorlevel% neq 0 (
    echo 관리자 권한으로 재실행합니다. UAC 창을 승인해주세요...
    powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c \"%~f0\"' -Verb RunAs -Wait"
    exit /b
)
cd /d "%~dp0"

echo.
echo ====================================================
echo      버블팝 그림책 - TWA 빌드 환경 자동 설치
echo ====================================================
echo  Node.js / Java JDK / Android SDK / Bubblewrap
echo  모든 도구를 자동으로 설치합니다.
echo  인터넷 연결을 확인해주세요.
echo ====================================================
echo.

:: ─────────────────────────────────────────────────
:: [1/5] Node.js LTS
:: ─────────────────────────────────────────────────
echo [1/5] Node.js 확인 중...
node --version > /dev/null 2>&1
if %errorlevel% equ 0 (
    for /f %%i in ('node --version') do echo  OK  Node.js %%i 이미 설치됨
    goto check_java
)

echo  --  Node.js LTS 설치 중 (winget)...
winget install --id OpenJS.NodeJS.LTS --silent --accept-source-agreements --accept-package-agreements
if %errorlevel% neq 0 (
    echo  X  Node.js 설치 실패.
    echo     수동 설치: https://nodejs.org
    pause & exit /b 1
)
for /f "tokens=*" %%i in ('powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable(\"PATH\",\"Machine\")+\";\"+ [Environment]::GetEnvironmentVariable(\"PATH\",\"User\")"') do set PATH=%%i
echo  OK  Node.js 설치 완료

:: ─────────────────────────────────────────────────
:: [2/5] Java JDK 17 (Temurin)
:: ─────────────────────────────────────────────────
:check_java
echo.
echo [2/5] Java JDK 확인 중...
java -version > /dev/null 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=* delims=" %%i in ('java -version 2^>^&1 ^| findstr version') do echo  OK  %%i 이미 설치됨
    goto check_android
)

echo  --  Java JDK 17 (Temurin) 설치 중 (winget)...
winget install --id EclipseAdoptium.Temurin.17.JDK --silent --accept-source-agreements --accept-package-agreements
if %errorlevel% neq 0 (
    echo  X  JDK 설치 실패.
    echo     수동 설치: https://adoptium.net
    pause & exit /b 1
)
for /f "tokens=*" %%i in ('powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable(\"PATH\",\"Machine\")+\";\"+ [Environment]::GetEnvironmentVariable(\"PATH\",\"User\")"') do set PATH=%%i
echo  OK  Java JDK 17 설치 완료

:: ─────────────────────────────────────────────────
:: [3/5] Android SDK (Command-line Tools)
:: ─────────────────────────────────────────────────
:check_android
echo.
echo [3/5] Android SDK 확인 중...
if defined ANDROID_HOME (
    echo  OK  ANDROID_HOME=%ANDROID_HOME% 이미 설정됨
    goto check_bubblewrap
)
if defined ANDROID_SDK_ROOT (
    echo  OK  ANDROID_SDK_ROOT=%ANDROID_SDK_ROOT% 이미 설정됨
    set ANDROID_HOME=%ANDROID_SDK_ROOT%
    goto check_bubblewrap
)
if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
    echo  OK  Android SDK 발견: %LOCALAPPDATA%\Android\Sdk
    setx ANDROID_HOME "%LOCALAPPDATA%\Android\Sdk" /M > /dev/null
    set ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk
    goto check_bubblewrap
)

echo  --  Android Command-line Tools 다운로드 중 (약 130MB)...
set "SDK_DIR=%LOCALAPPDATA%\Android\Sdk"
set "TOOLS_ZIP=%TEMP%\cmdline-tools.zip"
set "TOOLS_TMP=%TEMP%\cmdline-tools-tmp"
set "TOOLS_DIR=%SDK_DIR%\cmdline-tools\latest"

powershell -NoProfile -Command " ^
    $url = 'https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip'; ^
    Write-Host '  다운로드 중...'; ^
    Invoke-WebRequest -Uri $url -OutFile '%TOOLS_ZIP%' -UseBasicParsing; ^
    Write-Host '  압축 해제 중...'; ^
    Expand-Archive -Path '%TOOLS_ZIP%' -DestinationPath '%TOOLS_TMP%' -Force; ^
    New-Item -ItemType Directory -Force -Path '%TOOLS_DIR%' | Out-Null; ^
    Copy-Item -Path '%TOOLS_TMP%\cmdline-tools\*' -Destination '%TOOLS_DIR%' -Recurse -Force; ^
    Remove-Item '%TOOLS_TMP%' -Recurse -Force; ^
    Remove-Item '%TOOLS_ZIP%' -Force; ^
    Write-Host '  완료' ^
"
if %errorlevel% neq 0 (
    echo  X  Android SDK 다운로드 실패.
    echo     수동 설치: https://developer.android.com/studio#command-line-tools-only
    pause & exit /b 1
)

echo  --  필수 SDK 패키지 설치 중 (platform-tools, build-tools, android-34)...
echo y | "%TOOLS_DIR%\bin\sdkmanager.bat" --sdk_root="%SDK_DIR%" "platform-tools" "build-tools;34.0.0" "platforms;android-34"

setx ANDROID_HOME "%SDK_DIR%" /M > /dev/null
set ANDROID_HOME=%SDK_DIR%
echo  OK  Android SDK 설치 완료: %SDK_DIR%

:: ─────────────────────────────────────────────────
:: [4/5] Bubblewrap CLI
:: ─────────────────────────────────────────────────
:check_bubblewrap
echo.
echo [4/5] Bubblewrap CLI 확인 중...
bubblewrap --version > /dev/null 2>&1
if %errorlevel% equ 0 (
    for /f %%i in ('bubblewrap --version') do echo  OK  Bubblewrap %%i 이미 설치됨
    goto make_folder
)

echo  --  Bubblewrap CLI 설치 중...
npm install -g @bubblewrap/cli
if %errorlevel% neq 0 (
    echo  X  Bubblewrap 설치 실패. npm 권한을 확인하세요.
    pause & exit /b 1
)
echo  OK  Bubblewrap CLI 설치 완료

:: ─────────────────────────────────────────────────
:: [5/5] 빌드 폴더
:: ─────────────────────────────────────────────────
:make_folder
echo.
echo [5/5] 빌드 폴더 구성 중...
if not exist "twa-build" mkdir twa-build
echo  OK  twa-build\ 폴더 준비 완료

:: ─────────────────────────────────────────────────
:: 완료
:: ─────────────────────────────────────────────────
echo.
echo ====================================================
echo              모든 설치 완료!
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
