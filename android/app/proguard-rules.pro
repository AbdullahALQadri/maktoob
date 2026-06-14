# Maktoob Android ProGuard / R8 rules.
#
# Keeps Flutter and the third-party plugins we depend on alive after R8 strips
# unreferenced code in release builds. Add new rules below as plugins are added.

# ---------------------------------------------------------------------------
# Flutter / Dart
# ---------------------------------------------------------------------------
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ---------------------------------------------------------------------------
# Firebase / FCM
# ---------------------------------------------------------------------------
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# ---------------------------------------------------------------------------
# Kotlin
# ---------------------------------------------------------------------------
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**

# ---------------------------------------------------------------------------
# Mobile Scanner (zxing under the hood)
# ---------------------------------------------------------------------------
-keep class com.google.zxing.** { *; }
-dontwarn com.google.zxing.**

# ---------------------------------------------------------------------------
# Dio / OkHttp / Retrofit-style reflection
# ---------------------------------------------------------------------------
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn org.conscrypt.**

# ---------------------------------------------------------------------------
# Hive — uses generated TypeAdapters via reflection
# ---------------------------------------------------------------------------
-keep class * extends hive.HiveType { *; }
-keep class * extends hive.TypeAdapter { *; }

# ---------------------------------------------------------------------------
# Keep all native methods (JNI)
# ---------------------------------------------------------------------------
-keepclasseswithmembernames class * {
    native <methods>;
}

# ---------------------------------------------------------------------------
# Keep enums (their values() and valueOf() are accessed reflectively)
# ---------------------------------------------------------------------------
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
