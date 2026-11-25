#!/usr/bin/env bash
# Debug vs release check on a phone. Run it after any change to
# android/ (Gradle, manifest, proguard-rules.pro), after adding or upgrading
# a plugin, and before shipping a release APK.
#
# Why: release builds run R8, which shrinks and renames the plugins'
# Java/Kotlin code. Plugins that reach classes by reflection then break, and
# several fail silently: the document scanner fell back to its basic scanner
# (no auto capture) and ML Kit threw on every photo, while debug worked.
# Release also strips asserts, and the merged manifest can gain permissions
# from libraries (ML Kit's telemetry added INTERNET).
#
# What it does: builds tool/release_check/release_check_main.dart in debug
# and in release, runs both on the phone with the same receipts (PaddleOCR,
# ML Kit, PDF text layer, a scanned PDF; secure storage, encrypted SQLite,
# path_provider), and compares the outputs field by field: OCR boxes, rows
# and the parsed receipt (prices, VAT, quantities, discounts, totals) must be
# identical. It also fails if the release APK asks for INTERNET.
# Pickers, the scanner and "Salva con nome" open system screens and are
# checked by hand (release builds).
#
# The check app has the app's id, so it replaces the installed app (install
# -r: the user's data stays; the probes use their own files and keys). At the
# end the real release app is built and installed again (--no-reinstall to
# skip). Receipts pushed to the phone are deleted afterwards.
#
# Usage: tool/release_check/run.sh [-d DEVICE] [--photos DIR] [--pdfs DIR]
#        [--max-pdfs N] [--no-reinstall]
set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$root"
app=com.swe.scontrini
remote="/sdcard/Android/data/$app/files/release_check"
photos=data/scontrini_foto_reali
pdfs=data/scontrini/scontrini
max_pdfs=6
device=""
reinstall=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d) device="$2"; shift 2 ;;
    --photos) photos="$2"; shift 2 ;;
    --pdfs) pdfs="$2"; shift 2 ;;
    --max-pdfs) max_pdfs="$2"; shift 2 ;;
    --no-reinstall) reinstall=false; shift ;;
    *) echo "unknown option $1" >&2; exit 2 ;;
  esac
done

# Git Bash on Windows would rewrite /sdcard/... into a Windows path.
export MSYS_NO_PATHCONV=1

# Project-local SDK on Windows (.tooling), else what's on PATH.
flutter=flutter
if [[ -x .tooling/flutter/bin/flutter ]]; then
  flutter="$root/.tooling/flutter/bin/flutter"
  export FLUTTER_ROOT="$root/.tooling/flutter" PUB_CACHE="$root/.tooling/pub-cache" \
    GRADLE_USER_HOME="$root/.tooling/gradle"
  jbr="/c/Program Files/Android/Android Studio/jbr"
  [[ -z "${JAVA_HOME:-}" && -d "$jbr" ]] && export JAVA_HOME="$jbr"
fi
sdk="${ANDROID_HOME:-${LOCALAPPDATA:-}/Android/Sdk}"
adb=${ADB:-$(command -v adb || true)}
for candidate in "$sdk/platform-tools/adb" "$sdk/platform-tools/adb.exe"; do
  [[ -z "$adb" && -x "$candidate" ]] && adb="$candidate"
done
[[ -z "$adb" ]] && { echo "adb not found: set ADB=/path/to/adb" >&2; exit 1; }
aapt2=$(ls "$sdk"/build-tools/*/aapt2* 2>/dev/null | grep -v rc | tail -1 || true)
python=$(command -v python3 || command -v python)

adb_() { if [[ -n "$device" ]]; then "$adb" -s "$device" "$@"; else "$adb" "$@"; fi; }
# Relative paths: Windows Python can't read /c/... with MSYS_NO_PATHCONV set.
helper=tool/release_check/release_check.py
local_out=data/release_check
mkdir -p "$local_out"

# Inputs: the photos, the first PDFs, one scanned PDF made from a photo.
inputs=()
[[ -d "$photos" ]] && while IFS= read -r -d '' f; do inputs+=("$f"); done < <(
  find "$photos" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' \
    -o -iname '*.png' -o -iname '*.webp' \) -print0 | sort -z)
[[ -d "$pdfs" ]] && while IFS= read -r -d '' f; do inputs+=("$f"); done < <(
  find "$pdfs" -maxdepth 1 -type f -iname '*.pdf' -print0 | sort -z | head -z -n "$max_pdfs")
first_jpg=$(printf '%s\n' "${inputs[@]}" | grep -iE '\.jpe?g$' | head -1 || true)
if [[ -n "$first_jpg" ]]; then
  "$python" -I "$helper" scanned-pdf "$first_jpg" "$local_out/scanned_page.pdf"
  inputs+=("$local_out/scanned_page.pdf")
fi
if [[ ${#inputs[@]} -eq 0 ]]; then
  echo "No receipts: put photos in $photos and PDFs in $pdfs (git-ignored)." >&2
  exit 1
fi

echo "Pushing ${#inputs[@]} receipts..."
adb_ shell rm -rf "$remote"
adb_ shell mkdir -p "$remote/input" "$remote/truth"
for f in "${inputs[@]}"; do adb_ push "$f" "$remote/input/" >/dev/null 2>&1; done
for f in data/ground_truth/*; do [[ -f "$f" ]] && adb_ push "$f" "$remote/truth/" >/dev/null 2>&1; done

for mode in debug release; do
  echo "== $mode: building"
  "$flutter" build apk "--$mode" -t tool/release_check/release_check_main.dart >/dev/null
  adb_ install -r "build/app/outputs/flutter-apk/app-$mode.apk" >/dev/null
  # Remove the previous output first, or a stale `done` ends the wait early.
  adb_ shell rm -rf "$remote/out_$mode"
  adb_ shell am force-stop "$app"
  adb_ shell monkey -p "$app" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
  echo "== $mode: running on the phone"
  for _ in $(seq 1 200); do
    adb_ shell "test -f $remote/out_$mode/done" 2>/dev/null && break
    sleep 3
  done
  rm -rf "$local_out/out_$mode"
  adb_ pull "$remote/out_$mode" "$local_out/out_$mode" >/dev/null || true
done

status=0
"$python" -I "$helper" compare "$local_out/out_debug" "$local_out/out_release" || status=1

# The release manifest must not ask for INTERNET (no network, by design).
if [[ -n "$aapt2" ]]; then
  if "$aapt2" dump permissions build/app/outputs/flutter-apk/app-release.apk \
    | grep -q 'android.permission.INTERNET'; then
    echo "FAIL release APK asks for INTERNET (see AndroidManifest.xml)"; status=1
  else
    echo "ok   release APK has no INTERNET permission"
  fi
else
  echo "skip permission check: aapt2 not found under $sdk/build-tools"
fi

# Receipts are personal data: don't leave copies on the phone.
adb_ shell rm -rf "$remote"
if [[ "$reinstall" == true ]]; then
  echo "Reinstalling the real release app..."
  "$flutter" build apk --release >/dev/null
  adb_ install -r build/app/outputs/flutter-apk/app-release.apk >/dev/null
fi
echo "Outputs: $local_out (git-ignored)"
exit $status
