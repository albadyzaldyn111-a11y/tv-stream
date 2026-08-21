# Keep Flutter plugin entry points discoverable by the generated registrant.
-keep class io.flutter.plugins.** { *; }

# Video player implementations may reference platform codecs through reflection.
-keep class androidx.media3.** { *; }
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn androidx.media3.**
-dontwarn com.google.android.exoplayer2.**
