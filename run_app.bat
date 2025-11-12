@echo off
echo ========================================
echo  GoBeyond Travel App - Quick Start
echo ========================================
echo.

echo Checking Flutter...
flutter --version
if %errorlevel% neq 0 (
    echo Error: Flutter not found!
    pause
    exit /b 1
)

echo.
echo Checking connected devices...
flutter devices
echo.

echo ========================================
echo Starting app on emulator-5554...
echo ========================================
echo.

flutter run -d emulator-5554

pause

