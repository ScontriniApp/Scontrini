# R8 rules for the release build (the Flutter Gradle plugin picks this file up).

# google_mlkit_text_recognition references the Chinese, Devanagari, Japanese
# and Korean recognisers, each a separate Maven artifact. The app reads only
# Latin script, so they are left out on purpose (each adds several MB).
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
