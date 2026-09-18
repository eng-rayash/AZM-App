import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ملف التوقيع لا يدخل المستودع إطلاقًا — راجع android/key.properties.example
// وأضِف android/key.properties محليًا وفي بيئة البناء وحدها.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.rvios.app"
    compileSdk = flutter.compileSdkVersion
    // sqlite3_flutter_libs requires NDK 27.0 or higher
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.rvios.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    packagingOptions {
        // Avoid duplicate native libraries from sqlite3
        pickFirst("**/*.so")
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // التوقيع الحقيقي حين يوجد key.properties، ومفتاح التصحيح حين
            // لا يوجد حتى يبقى `flutter run --release` ممكنًا محليًا.
            //
            // حزمة موقَّعة بمفتاح التصحيح لا يقبلها Google Play، ولذلك
            // يُطبع تحذير صريح عند البناء بدل أن يمرّ الأمر صامتًا.
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                logger.warn(
                    "⚠  بناء إصدار بمفتاح التصحيح: لا يوجد android/key.properties. " +
                    "هذه الحزمة غير صالحة للنشر على Google Play."
                )
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
