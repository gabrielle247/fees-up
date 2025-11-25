import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // 1. ✅ MATCHING YOUR KOTLIN FILE
    namespace = "com.example.fees_up"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // 2. ✅ UPDATED APP ID TO MATCH
        applicationId = "com.gabrielle247.fees_up"
        
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // 3. ✅ DISABLE MINIFICATION (Fixes SQFlite)
            // Prevents R8 from deleting database/auth code
            isMinifyEnabled = false 
            isShrinkResources = false

            // Signing with debug key (Okay for GitHub Actions test)
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 4. ✅ REMOVED BROKEN MATERIAL DEPENDENCY
    // Flutter handles material design automatically. 
    // You rarely need to add extra dependencies here.
}
