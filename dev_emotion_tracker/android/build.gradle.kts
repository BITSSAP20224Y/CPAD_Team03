// android/build.gradle.kts

plugins {
    // Apply the Android Library plugin
    id("com.android.library")
    // Apply the Kotlin Android plugin if your library uses Kotlin
    kotlin("android")
}

android {
    // Defines the namespace for your Android library
    namespace = "com.tflite_v2"

    // Specifies the Android API level to compile against
    compileSdk = 33 // You can adjust this to your desired SDK version

    defaultConfig {
        // Defines the minimum Android API level required to run the app
        minSdk = 21 // You can adjust this based on your project's needs

        // Specifies the instrumentation runner for Android tests
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"

        // Specifies ProGuard rules files for shrinking, optimizing, and obfuscating your code
        consumerProguardFiles("consumer-rules.pro", "proguard-android-optimize.txt")
    }

    // Configures lint options to disable specific checks
    lintOptions {
        disable("InvalidPackage") // Disables the 'InvalidPackage' lint check
    }

    // Configures Java compatibility options for compilation
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8 // Sets source compatibility to Java 8
        targetCompatibility = JavaVersion.VERSION_1_8 // Sets target compatibility to Java 8
    }
}

dependencies {
    // Include all JAR files from the 'libs' directory
    implementation(fileTree(mapOf("dir" to "libs", "include" to listOf("*.jar"))))

    // TensorFlow Lite dependencies
    implementation("org.tensorflow:tensorflow-lite:2.8.0")
    implementation("org.tensorflow:tensorflow-lite-gpu:2.8.0")

    // Core AndroidX KTX library for Kotlin extensions
    implementation("androidx.core:core-ktx:1.13.1")

    // JUnit for unit testing
    testImplementation("junit:junit:4.13.2")

    // AndroidX Test Ext JUnit for Android unit tests
    androidTestImplementation("androidx.test.ext:junit:1.1.5")

    // AndroidX Espresso Core for UI testing
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
}