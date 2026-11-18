#!/usr/bin/env bash
cd preview 2>/dev/null || exit 0
find . -type f -empty -delete
ls -A | grep -q . || exit 0
if ! gh release view "$RF_TAG" --repo "$GITHUB_REPOSITORY" >/dev/null 2>&1; then
  gh release create "$RF_TAG" --repo "$GITHUB_REPOSITORY" --title "Emulator preview $RF_TAG" --notes "Screenshots and permission state from a real Android 11 emulator (API 30) run by RepoForge." || true
fi
for f in ./*; do
  gh release upload "$RF_TAG" "$f" --clobber --repo "$GITHUB_REPOSITORY" || echo "::warning::could not upload $f"
done
