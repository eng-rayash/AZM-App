# Flutter Wrapper Keep Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class class.of.your.GeneratedPluginRegistrant { *; }

# Keep sqlite & SQLCipher libs
-keep class org.sqlite.** { *; }
-keep class net.sqlcipher.** { *; }
-keep class net.sqlcipher.database.** { *; }

# Secure Storage keep rules
-keep class com.it_dr.flutter_secure_storage.** { *; }

# Prevent obfuscation of serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Flutter's deferred components reference Play Core, which this app doesn't ship (R8: missing classes)
-dontwarn com.google.android.play.core.**

# flutter_local_notifications serialises scheduled notifications with Gson — keep its models in release
-keep class com.dexterous.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
