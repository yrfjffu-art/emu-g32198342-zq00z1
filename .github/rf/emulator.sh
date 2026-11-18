#!/usr/bin/env bash
BT="$ANDROID_HOME/build-tools/$(ls "$ANDROID_HOME/build-tools" | sort -V | tail -1)"
PKG="$("$BT/aapt2" dump packagename emu/app.apk)"
mkdir -p preview
echo "package=$PKG" > preview/device.txt
adb shell getprop ro.product.model >> preview/device.txt
adb shell getprop ro.build.version.release >> preview/device.txt
if ! adb install -r emu/app.apk > preview/install.txt 2>&1; then echo "INSTALL FAILED"; cat preview/install.txt; exit 0; fi
adb shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
sleep 18
adb exec-out screencap -p > preview/screen-1-launch.png
adb shell dumpsys package "$PKG" | grep -E "android.permission.[A-Z_]+: granted=(true|false)" | sort -u > preview/permissions-before.txt
for p in $(adb shell dumpsys package "$PKG" | grep -oE "android.permission.[A-Z_]+: granted=false" | cut -d: -f1 | sort -u); do adb shell pm grant "$PKG" "$p" >/dev/null 2>&1; done
adb shell am force-stop "$PKG"
adb shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
sleep 14
adb exec-out screencap -p > preview/screen-2-granted.png
adb shell dumpsys package "$PKG" | grep -E "android.permission.[A-Z_]+: granted=(true|false)" | sort -u > preview/permissions-after.txt
adb logcat -d -b crash > preview/crash.txt 2>/dev/null
ls -la preview
