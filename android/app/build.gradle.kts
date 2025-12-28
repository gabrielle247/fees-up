// 1. ADD THIS BLOCK BEFORE 'android {'
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    namespace "com.greyway.fees_up" // Ensure this matches your package name
    compileSdk 34 

    defaultConfig {
        applicationId "com.greyway.fees_up"
        minSdk 23
        targetSdk 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    // 2. CONFIGURE SIGNING
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            // 3. APPLY THE SIGNING CONFIG HERE
            signingConfig signingConfigs.release
            
            // Keep these false for now to avoid errors with code shrinking
            minifyEnabled false 
            shrinkResources false
        }
    }
}