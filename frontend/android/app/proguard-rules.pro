# Jitsi Meet SDK
-keep class org.jitsi.meet.** { *; }
-keep class org.jitsi.meet.sdk.** { *; }

# React Native (used internally by Jitsi Meet SDK)
-keep class com.facebook.react.** { *; }
-keep class com.facebook.hermes.** { *; }
-keep class com.facebook.jni.** { *; }

# WebRTC
-keep class org.webrtc.** { *; }

# Jitsi Flutter plugin
-keep class org.jitsi.jitsi_meet_flutter_sdk.** { *; }

# Keep Gson type adapters used by Jitsi
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep WriteConfigChangedBroadcastReceiver used by Jitsi
-keep class org.jitsi.meet.sdk.WriteConfigChangedBroadcastReceiver { *; }

# OkHttp (used by Jitsi)
-dontwarn okhttp3.**
-dontwarn okio.**
