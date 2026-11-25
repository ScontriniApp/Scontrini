# google_mlkit_text_recognition references the Chinese, Devanagari, Japanese
# and Korean recognisers, which the app doesn't bundle (Latin script only).
# Without these rules R8 fails the release build on the missing classes.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
