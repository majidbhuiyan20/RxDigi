import java.util.Properties as JProperties
import java.io.FileInputStream as JFileInputStream

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.matox.prescripto"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.matox.prescripto"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        val keystorePropertiesFile = rootProject.file("key.properties")
        val props = JProperties()
        if (keystorePropertiesFile.exists()) {
            JFileInputStream(keystorePropertiesFile).use { stream ->
                props.load(stream)
            }
        }

        getByName("debug") {
            // Default debug config
        }

        create("release") {
            keyAlias = props.getProperty("keyAlias")
            keyPassword = props.getProperty("keyPassword")
            props.getProperty("storeFile")?.let { path ->
                storeFile = file(path)
            }
            storePassword = props.getProperty("storePassword")
        }
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
        getByName("release") {
            signingConfig = if (rootProject.file("key.properties").exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
