#!/usr/bin/env bash
mkdir -p out
BT="$ANDROID_HOME/build-tools/$(ls "$ANDROID_HOME/build-tools" | sort -V | tail -1)"
find . -path ./out -prune -o -path '*/build/outputs/*' \( -name '*.apk' -o -name '*.aab' \) -print | while read -r f; do cp "$f" out/; done
if [ -z "$RF_STORE_FILE" ]; then
  keytool -genkeypair -keystore "$RUNNER_TEMP/ci.jks" -storepass rfci-pass -keypass rfci-pass -alias rf -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=RepoForge CI" >/dev/null 2>&1
fi
for f in out/*.apk; do
  [ -e "$f" ] || continue
  if "$BT/apksigner" verify "$f" >/dev/null 2>&1; then continue; fi
  n="$(dirname "$f")/$(basename "$f" .apk)"; n="$(echo "$n" | sed 's/-unsigned$//')"
  "$BT/zipalign" -f -p 4 "$f" "$n-aligned.apk"
  if [ -n "$RF_STORE_FILE" ]; then
    "$BT/apksigner" sign --ks "$RF_STORE_FILE" --ks-pass env:RF_STORE_PASSWORD --ks-key-alias "$RF_KEY_ALIAS" --key-pass env:RF_KEY_PASSWORD --out "$n-signed.apk" "$n-aligned.apk"
  else
    "$BT/apksigner" sign --ks "$RUNNER_TEMP/ci.jks" --ks-pass pass:rfci-pass --key-pass pass:rfci-pass --ks-key-alias rf --out "$n-ci-signed.apk" "$n-aligned.apk"
  fi
  rm -f "$f" "$n-aligned.apk"
done
rm -f out/*.idsig
for f in out/*.aab; do
  [ -e "$f" ] || continue
  if jarsigner -verify "$f" 2>/dev/null | grep -q "jar verified"; then continue; fi
  if [ -n "$RF_STORE_FILE" ]; then
    jarsigner -keystore "$RF_STORE_FILE" -storepass "$RF_STORE_PASSWORD" -keypass "$RF_KEY_PASSWORD" "$f" "$RF_KEY_ALIAS" >/dev/null 2>&1 || echo "AAB signing failed"
  fi
done
for f in out/*.apk; do
  [ -e "$f" ] || continue
  echo "== $(basename "$f")"
  "$BT/aapt2" dump badging "$f" 2>/dev/null | grep -E "^(package|sdkVersion|minSdkVersion|targetSdkVersion|uses-permission|application-label|launchable-activity|native-code)"
done > out/report.txt
ls -la out
