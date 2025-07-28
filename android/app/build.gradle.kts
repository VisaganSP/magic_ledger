plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.visainnovations.magic_ledger"
    compileSdk = 35  // Updated to SDK 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        // Add this line for core library desugaring
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.visainnovations.magic_ledger"
        minSdk = 21  // Minimum SDK for notifications
        targetSdk = 34  // Keep target SDK at 34 for now
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")

    // Add this line for core library desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}