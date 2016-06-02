# Cookpit
Flickr API implementation for Android with C++ core

## Requirement
* android ndk and `ndk-build` on your PATH to build for android

## Installation
* Run `make android` at root folder

## Building
* Import `Cookpit/` into Android Studio

## Bridging Code
* `Cookpit/java_gen` and `Cookpit/jni_gen` contains all bridging code in Java/JNI generated by djinni's interface files in `djinni/`

## Folder structure
```bash
Cookpit
├── app/ # app module for Android app
├── gradle/ # gradle tool
├── java_gen/ # bridging code (untrack)
├── jni/ # jni configuration Android.mk & Application.mk
├── jni_gen/ # bridging code (untrack)
└── build.gradle # gradle configuration file
```