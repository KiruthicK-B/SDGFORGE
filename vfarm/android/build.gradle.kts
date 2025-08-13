allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
plugins {
    kotlin("android") version "2.2.0" apply false 
    id("com.android.application") version "8.7.0" apply false
    id("com.google.gms.google-services") version "4.4.3" apply false
}


val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
