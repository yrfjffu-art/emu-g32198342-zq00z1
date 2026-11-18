#!/usr/bin/env bash
set -o pipefail
mkdir -p out
if [ -f ./gradlew ]; then chmod +x ./gradlew; G=./gradlew; else G=gradle; fi
echo "RF> $G $RF_TASKS $RF_FLAGS"
$G $RF_TASKS $RF_FLAGS --no-daemon --stacktrace 2>&1 | tee out/build.log
