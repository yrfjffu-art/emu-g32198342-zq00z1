#!/usr/bin/env bash
cd out 2>/dev/null || exit 0
find . -type f -empty -delete
ls -A | grep -q . || exit 0
if ! gh release view "$RF_TAG" --repo "$GITHUB_REPOSITORY" >/dev/null 2>&1; then
  gh release create "$RF_TAG" --repo "$GITHUB_REPOSITORY" --title "Build $RF_TAG" --notes "Built by RepoForge with GitHub Actions. APK/AAB outputs, build.log and report.txt (aapt2) are attached." || true
fi
for f in ./*; do
  gh release upload "$RF_TAG" "$f" --clobber --repo "$GITHUB_REPOSITORY" || echo "::warning::could not upload $f"
done
