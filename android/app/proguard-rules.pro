# R8 rules for release builds (debug builds don't run R8).
#
# R8 shrinks, renames and inlines the Java/Kotlin code of every plugin.
# Code that reaches classes by reflection (Google Play services and ML Kit do
# a lot of it) then breaks in release only, and often SILENTLY: plugins catch
# the exception and fall back to something worse. Dart code is not affected
# (R8 never sees it; ONNX Runtime, pdfrx and SQLite are reached through
# dart:ffi, also unaffected).
#
# Rules of thumb:
# - A plugin that "works in debug only" is R8 until proven otherwise:
#   `adb logcat` shows obfuscated class names (a.b.c, r8-map-id) in the trace,
#   and build/app/outputs/mapping/release/mapping.txt maps them back.
# - Keep whole packages of Google SDKs that work by reflection; size cost is
#   small (these rules add < 1 MB).
# - After touching this file, a plugin or android/: tool/release_check/run.sh.
#   It runs the same receipts through a debug and a release build on a phone
#   and fails on any difference.

# google_mlkit_text_recognition references the Chinese, Devanagari, Japanese
# and Korean recognisers, which the app doesn't bundle (Latin script only).
# Without these rules R8 fails the release build on the missing classes.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# cunning_document_scanner starts Google's ML Kit document scanner (auto
# capture, edge detection) and silently falls back to its own basic scanner
# when that call throws. R8 renamed or stripped classes the scanner loads by
# reflection, so release builds always got the fallback: keep them whole.
-keep class com.google.mlkit.vision.documentscanner.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_document_scanner.** { *; }
-keep class com.google.mlkit.common.** { *; }
-keep class com.google.android.gms.common.moduleinstall.** { *; }
-keep class biz.cunning.cunning_document_scanner.** { *; }

# Same for ML Kit text recognition (photo fallback, scanned PDFs): in release
# every recognise call threw a NullPointerException inside the R8-optimised
# com.google.mlkit.vision.text.internal classes. Checked by running the same
# photos through a debug and a release build on a phone.
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.vision.common.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_common.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_common.** { *; }
-keep class com.google_mlkit_text_recognition.** { *; }
-keep class com.google_mlkit_commons.** { *; }
