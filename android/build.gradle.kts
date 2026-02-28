plugins {
    // Android version 8.11.1 (Jo aapke system ki demand thi)
    id("com.android.application") version "8.11.1" apply false
    
    // Kotlin version 2.2.20 (Jo error ne manga tha)
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    
    // 🔥 Yahan se version "1.0.0" hata diya hai taake unknown version conflict khatam ho
    id("dev.flutter.flutter-gradle-plugin") apply false
    
    // Firebase Google Services (Aapka previous logic)
    id("com.google.gms.google-services") version "4.3.15" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Build directory configuration (Aapka logic bilkul safe hai)
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}