#!/usr/bin/env bash
if [ -n "$RF_KS" ]; then
  echo "$RF_KS" | base64 -d > "$RUNNER_TEMP/rf.jks"
  echo "RF_STORE_FILE=$RUNNER_TEMP/rf.jks" >> "$GITHUB_ENV"
  echo "Signing keystore installed."
else
  echo "No keystore secret: release APKs use the debug or a CI key."
fi
