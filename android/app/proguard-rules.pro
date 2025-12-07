# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Play Services / AdMob
-keep class com.google.android.gms.** { *; }
-keep class com.google.ads.** { *; }
-dontwarn com.google.android.gms.**

# In-App Billing
-keep class com.android.vending.billing.** { *; }

# Hive database
-keep class * extends com.google.protobuf.GeneratedMessageLite { *; }
-keep class hive.** { *; }
-keep class ** extends hive.TypeAdapter { *; }

# Keep model classes for Hive
-keep class com.kardashev.kardashev_ascension.** { *; }

# Audioplayers
-keep class xyz.luan.audioplayers.** { *; }
