# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# SQFlite - Prevent stripping database drivers
-keep class com.tekartik.sqflite.** { *; }

# Supabase / Json Serialization
-keep class com.gabrielle247.fees_up.models.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
