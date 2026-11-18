#!/usr/bin/env bash
mkdir -p emu
gh release download "$RF_SRC_TAG" --repo "$GITHUB_REPOSITORY" --pattern '*.apk' --dir emu
APK="$(ls emu/*.apk | grep -i debug | head -1)"
[ -n "$APK" ] || APK="$(ls emu/*.apk | head -1)"
[ -n "$APK" ] || { echo "No APK found in release $RF_SRC_TAG"; exit 1; }
cp "$APK" emu/app.apk
echo "Testing $APK"
