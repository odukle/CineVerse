# Keep Flutter plugins and engine classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Drift and Sqlite classes
-keep class com.drift.** { *; }
-keep class io.requery.android.database.** { *; }
-keep class org.sqlite.database.** { *; }

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Ignore warnings for Play Core deferred components
-dontwarn com.google.android.play.core.**
