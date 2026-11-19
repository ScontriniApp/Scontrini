#!/usr/bin/env bash
# Copies receipts exported from the app ("Export as test" on the result
# screen, debug builds only) into assets/test_receipts/incoming/.
#
# The files live in the app's private storage, so this uses `run-as`, which
# works over USB on debug builds. incoming/ is git-ignored: redact the files,
# write the .expected.json, then move them up into assets/test_receipts/.
#
# Usage: tool/pull_fixtures.sh [--clear]   (--clear deletes them from the phone)
set -euo pipefail

app=com.swe.scontrini
dest="$(cd "$(dirname "$0")/.." && pwd)/assets/test_receipts/incoming"
mkdir -p "$dest"

files=$(adb shell run-as "$app" ls files/fixtures 2>/dev/null | tr -d '\r' || true)
if [[ -z "$files" ]]; then
  echo "No exported receipts on the device."
  exit 0
fi

for f in $files; do
  adb exec-out run-as "$app" cat "files/fixtures/$f" > "$dest/$f"
  echo "pulled $f"
done

if [[ "${1:-}" == "--clear" ]]; then
  adb shell run-as "$app" rm -r files/fixtures
  echo "cleared the device copies"
fi
