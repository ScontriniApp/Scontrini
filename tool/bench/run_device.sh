#!/usr/bin/env bash
# Runs the extraction benchmark on a phone or emulator (ML Kit only runs
# there): pushes the receipts and the ground truth into the app's external
# files folder, runs integration_test/bench/device_bench_test.dart, then pulls
# the report and the raw ML Kit output back into data/.
#
# Usage: tool/bench/run_device.sh [options]
#   -d ID          device id (see `flutter devices`); default: the only one
#   --photos DIR   folder with the photos       (default data/scontrini_foto_reali)
#   --pdfs DIR     also run the PDFs in DIR on the device (e.g. data/scontrini/scontrini)
#   --keep         leave the receipts on the device afterwards
#   --only TEXT    only the receipts whose file name contains TEXT
#   --paddle       read photos with PaddleOCR (PP-OCRv6, onnxruntime); the
#                  models (data/modelli/paddle) are pushed once into
#                  paddle-model/ and left there (--remove-model deletes them)
#   --paddle-size tiny|small|medium, --paddle-threads N
#
# Output:
#   data/bench_runs/<timestamp>_device.json   full report (summary printed too)
#   data/ocr_cache/<name>.ocr.json            ML Kit output per photo, so
#        `flutter test tool/bench/desktop_bench_test.dart` can replay the
#        photos on the PC while working on the row builder or the parser.
set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$root"
app=com.swe.scontrini
remote="/sdcard/Android/data/$app/files/bench"
photos=data/scontrini_foto_reali
pdfs=""
device=""
keep=false
only=""
defines=()
remove_model=false
paddle=false
paddle_size=small
paddle_dir=data/modelli/paddle

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d) device="$2"; shift 2 ;;
    --photos) photos="$2"; shift 2 ;;
    --pdfs) pdfs="$2"; shift 2 ;;
    --keep) keep=true; shift ;;
    --only) only="$2"; shift 2 ;;
    --remove-model) remove_model=true; shift ;;
    --paddle) paddle=true; defines+=(--dart-define=BENCH_PADDLE=true); shift ;;
    --paddle-size) paddle_size="$2"; defines+=("--dart-define=BENCH_PADDLE_SIZE=$2"); shift 2 ;;
    --paddle-threads) defines+=("--dart-define=BENCH_PADDLE_THREADS=$2"); shift 2 ;;
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
adb=${ADB:-$(command -v adb || true)}
for candidate in "${ANDROID_HOME:-}/platform-tools/adb" \
  "${LOCALAPPDATA:-}/Android/Sdk/platform-tools/adb.exe"; do
  [[ -z "$adb" && -x "$candidate" ]] && adb="$candidate"
done
[[ -z "$adb" ]] && { echo "adb not found: set ADB=/path/to/adb" >&2; exit 1; }

adb_() { if [[ -n "$device" ]]; then "$adb" -s "$device" "$@"; else "$adb" "$@"; fi; }

inputs=()
[[ -d "$photos" ]] && while IFS= read -r -d '' f; do inputs+=("$f"); done < <(
  find "$photos" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' \
    -o -iname '*.png' -o -iname '*.webp' -o -iname '*.bmp' \) -print0)
[[ -n "$pdfs" ]] && while IFS= read -r -d '' f; do inputs+=("$f"); done < <(
  find "$pdfs" -maxdepth 1 -type f -iname '*.pdf' -print0)
if [[ -n "$only" ]]; then
  kept=()
  for f in "${inputs[@]}"; do [[ "$(basename "$f")" == *"$only"* ]] && kept+=("$f"); done
  inputs=("${kept[@]}")
fi
if [[ ${#inputs[@]} -eq 0 ]]; then
  echo "Nothing to run: put photos in $photos (or pass --pdfs DIR)." >&2
  exit 1
fi

# Installing the test app may wipe its folders, so the test creates them,
# writes `ready`, and waits for `go` before reading the receipts.
# --no-uninstall: uninstalling would delete the report before it is pulled.
adb_ shell rm -rf "$remote"
# BENCH_FLUTTER_ARGS: extra flags for flutter test (e.g. -v to debug a run).
"$flutter" test ${BENCH_FLUTTER_ARGS:-} integration_test/bench/device_bench_test.dart \
  ${device:+-d "$device"} --no-uninstall --dart-define=BENCH=true ${defines[@]+"${defines[@]}"} &
test_pid=$!

echo "Waiting for the app to start on the device..."
until adb_ shell "test -f $remote/ready" 2>/dev/null; do
  kill -0 "$test_pid" 2>/dev/null || { wait "$test_pid"; exit 1; }
  sleep 2
done
# small is in the app's assets: nothing to push.
if [[ "$paddle" == true && "$paddle_size" != small ]]; then
  paddle_remote="/sdcard/Android/data/$app/files/paddle-model"
  adb_ shell mkdir -p "$paddle_remote"
  for f in "$paddle_dir/PP-OCRv6_det_$paddle_size.onnx" "$paddle_dir/PP-OCRv6_rec_$paddle_size.onnx"       "$paddle_dir/PP-OCRv6_rec_characters.txt"; do
    size=$(wc -c < "$f" | tr -d ' ')
    remote_size=$(adb_ shell "stat -c %s $paddle_remote/$(basename "$f") 2>/dev/null" | tr -d '\r' || true)
    if [[ "$size" != "$remote_size" ]]; then
      echo "Pushing $(basename "$f") ($((size / 1000000)) MB)..."
      adb_ push "$f" "$paddle_remote/" >/dev/null
    fi
  done
fi
echo "Pushing ${#inputs[@]} receipts and the ground truth..."
for f in "${inputs[@]}"; do adb_ push "$f" "$remote/input/" >/dev/null 2>&1; done
for f in data/ground_truth/*; do adb_ push "$f" "$remote/truth/" >/dev/null 2>&1; done
adb_ shell "touch $remote/go"
wait "$test_pid"

stamp=$(date +%Y-%m-%dT%H-%M-%S)
mkdir -p data/bench_runs data/ocr_cache
adb_ pull "$remote/out/report.json" "data/bench_runs/${stamp}_device.json" >/dev/null 2>&1
if [[ "$paddle" == true ]]; then
  # Saved where desktop_bench_test.dart scores it as its own group.
  mkdir -p "data/ocr_cache/paddle_device-v6-$paddle_size"
  adb_ shell "ls $remote/out/ocr_paddle" | tr -d '\r' | while read -r f; do
    [[ -n "$f" ]] && adb_ pull "$remote/out/ocr_paddle/$f" "data/ocr_cache/paddle_device-v6-$paddle_size/$f" >/dev/null 2>&1
  done
else
  adb_ shell "ls $remote/out/ocr" | tr -d '\r' | while read -r f; do
    [[ -n "$f" ]] && adb_ pull "$remote/out/ocr/$f" "data/ocr_cache/$f" >/dev/null 2>&1
  done
fi
echo "Report: data/bench_runs/${stamp}_device.json"

if [[ "$keep" == false ]]; then
  # The receipts are personal data: don't leave copies on the device.
  adb_ shell rm -rf "$remote"
fi
if [[ "$remove_model" == true ]]; then
  # glm-model/: left on phones by the removed GLM-OCR benchmark.
  adb_ shell rm -rf "/sdcard/Android/data/$app/files/glm-model" "/sdcard/Android/data/$app/files/paddle-model"
fi
