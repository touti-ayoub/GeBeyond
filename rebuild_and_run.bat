@echo off
echo ========================================
echo  Rebuilding App for Stripe Fix
echo ========================================
echo.

cd /d "%~dp0"

echo Step 1: Stopping any running instances...
adb shell am force-stop com.gobeyond.gobeyond_app
timeout /t 2 /nobreak >nul

echo.
echo Step 2: Cleaning build files...
flutter clean

echo.
echo Step 3: Getting dependencies...
flutter pub get

echo.
echo Step 4: Rebuilding and running app...
flutter run -d emulator-5554

pause

