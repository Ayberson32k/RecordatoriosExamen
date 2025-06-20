plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.recordatorioo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true // CAMBIO A isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8 // CAMBIO A VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8 // CAMBIO A VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8" // CAMBIO A "1.8"
    }

    defaultConfig {
        applicationId = "com.example.recordatorioo"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") // CAMBIO A coreLibraryDesugaring("...")
}