@echo off
chcp 437 > nul
cd /d "%~dp0"

echo.
echo ====================================================
echo   Bubble Pop - TWA Build Environment Setup
echo ====================================================
echo   Checking: Node.js / Java JDK / Android SDK
echo             / Bubblewrap
echo   Please make sure you are connected to internet.
echo ====================================================
echo.

:: Check admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo   WARNING: Not running as Administrator.
    echo   ANDROID_HOME env variable may not be set.
    echo   Right-click this file and choose
    echo   "Run as administrator" for full setup.
    echo.
    pause
    echo.
)

:: -------------------------------------------------
:: [1/5] Node.js LTS
:: -------------------------------------------------
echo [1/5] Checking Node.js...
node --version > nul 2>&1
if %errorlevel% equ 0 (
    for /f %%i in ('node --version') do echo  OK  Node.js %%i already installed
    goto check_java
)

echo  --  Installing Node.js LTS via winget...
winget install --id OpenJS.NodeJS.LTS --silent --accept-source-agreements --accept-package-agreements
if %errorlevel% neq 0 (
    echo  X  Node.js install FAILED.
    echo     Manual install: https://nodejs.org
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable(\"PATH\",\"Machine\")+\";\"+ [Environment]::GetEnvironmentVariable(\"PATH\",\"User\")"') do set PATH=%%i
echo  OK  Node.js installed

:: -------------------------------------------------
:: [2/5] Java JDK 17 (Temurin)
:: -------------------------------------------------
:check_java
echo.
echo [2/5] Checking Java JDK...
java -version > nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=* delims=" %%i in ('java -version 2^>^&1 ^| findstr version') do echo  OK  %%i already installed
    goto check_android
)

echo  --  Installing Java JDK 17 (Temurin) via winget...
winget install --id EclipseAdoptium.Temurin.17.JDK --silent --accept-source-agreements --accept-package-agreements
if %errorlevel% neq 0 (
    echo  X  JDK install FAILED.
    echo     Manual install: https://adoptium.net
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable(\"PATH\",\"Machine\")+\";\"+ [Environment]::GetEnvironmentVariable(\"PATH\",\"User\")"') do set PATH=%%i
echo  OK  Java JDK 17 installed

:: -------------------------------------------------
:: [3/5] Android SDK (Command-line Tools)
:: -------------------------------------------------
:check_android
echo.
echo [3/5] Checking Android SDK...
if defined ANDROID_HOME (
    echo  OK  ANDROID_HOME=%ANDROID_HOME%
    goto check_bubblewrap
)
if defined ANDROID_SDK_ROOT (
    echo  OK  ANDROID_SDK_ROOT=%ANDROID_SDK_ROOT%
    set ANDROID_HOME=%ANDROID_SDK_ROOT%
    goto check_bubblewrap
)
if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
    echo  OK  Android SDK found: %LOCALAPPDATA%\Android\Sdk
    setx ANDROID_HOME "%LOCALAPPDATA%\Android\Sdk" > nul 2>&1
    setx ANDROID_HOME "%LOCALAPPDATA%\Android\Sdk" /M > nul 2>&1
    set ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk
    goto check_bubblewrap
)

echo  --  Downloading Android Command-line Tools (~130MB)...
set "SDK_DIR=%LOCALAPPDATA%\Android\Sdk"
set "TOOLS_ZIP=%TEMP%\cmdline-tools.zip"
set "TOOLS_TMP=%TEMP%\cmdline-tools-tmp"
set "TOOLS_DIR=%SDK_DIR%\cmdline-tools\latest"

powershell -NoProfile -Command "$url='https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip'; Write-Host '  Downloading...'; Invoke-WebRequest -Uri $url -OutFile '%TOOLS_ZIP%' -UseBasicParsing; Write-Host '  Extracting...'; Expand-Archive -Path '%TOOLS_ZIP%' -DestinationPath '%TOOLS_TMP%' -Force; New-Item -ItemType Directory -Force -Path '%TOOLS_DIR%' | Out-Null; Copy-Item -Path '%TOOLS_TMP%\cmdline-tools\*' -Destination '%TOOLS_DIR%' -Recurse -Force; Remove-Item '%TOOLS_TMP%' -Recurse -Force; Remove-Item '%TOOLS_ZIP%' -Force; Write-Host '  Done'"
if %errorlevel% neq 0 (
    echo  X  Android SDK download FAILED.
    echo     Manual: https://developer.android.com/studio#command-line-tools-only
    pause
    exit /b 1
)

echo  --  Installing SDK packages (platform-tools, build-tools, android-34)...
echo y | "%TOOLS_DIR%\bin\sdkmanager.bat" --sdk_root="%SDK_DIR%" "platform-tools" "build-tools;34.0.0" "platforms;android-34"

setx ANDROID_HOME "%SDK_DIR%" > nul 2>&1
setx ANDROID_HOME "%SDK_DIR%" /M > nul 2>&1
set ANDROID_HOME=%SDK_DIR%
echo  OK  Android SDK installed: %SDK_DIR%

:: -------------------------------------------------
:: [4/5] Bubblewrap CLI
:: -------------------------------------------------
:check_bubblewrap
echo.
echo [4/5] Checking Bubblewrap CLI...
bubblewrap --version > nul 2>&1
if %errorlevel% equ 0 (
    for /f %%i in ('bubblewrap --version') do echo  OK  Bubblewrap %%i already installed
    goto make_folder
)

echo  --  Installing Bubblewrap CLI via npm...
npm install -g @bubblewrap/cli
if %errorlevel% neq 0 (
    echo  X  Bubblewrap install FAILED.
    pause
    exit /b 1
)
echo  OK  Bubblewrap CLI installed

:: -------------------------------------------------
:: [5/5] Build folder
:: -------------------------------------------------
:make_folder
echo.
echo [5/5] Setting up build folder...
if not exist "twa-build" mkdir twa-build
echo  OK  twa-build\ folder ready

:: -------------------------------------------------
:: Done
:: -------------------------------------------------
echo.
echo ====================================================
echo   Setup Complete!
echo ====================================================
echo   Next: see BUILD_GUIDE.md for full instructions.
echo.
echo   Quick start:
echo     1. Edit twa-manifest.json
echo        Replace YOUR_GITHUB_USERNAME with your name
echo     2. cd twa-build
echo     3. bubblewrap init --manifest ../twa-manifest
echo     4. bubblewrap build
echo ====================================================
echo.
pause
