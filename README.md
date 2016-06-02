# Cookpit
Flickr API implementation for Android/iOS with C++ core

## Requirement
* `python` (required for gyp)
* xcode & `xcodebuild`
* android ndk and `ndk-build` on your PATH to build for android
* Configure the paths to your [Android SDK](http://developer.android.com/sdk/installing/index.html)
  and [Android NDK](http://developer.android.com/tools/sdk/ndk/index.html) in your `local.properties`

## Installation
* Run `make lib` to build xcodeproj for shared library.
* Run `make ios` to build library for iOS project, located under ios/
* Run `make android` to trigger `ndk-build` for Android project, located under android/

## Building
* Running any `make` command will automatically download [gyp](https://code.google.com/p/gyp/) and create
`.xcodeproj` files suitable for developing on each platform.

Make targets:
* `clean` - clean all generated files
* `ios` - build library name `libcookpit.a`, `libcookpit_ios.a` suitable for iOS
* `android` - build library name `libcookpit_android.so` suitable for Android

## Folder structure
```bash
├── android/ # Android app (Android studio project)
├── cpp/ # Core cpp code
├── djinni/ # [Djinni](https://github.com/dropbox/djinni) interface files
├── ios/ # iOS app (open .xcworkspace)
├── lib/ # xcodeproj for develop C++
├── utils/ # tools for tedious works, glob, clang-format etc.
├── vendors/ # 3rd party libraries and 3rd party libraries for C++ (gyp, djinni is also here)
├── common.gypi/ # gyp configuration file (common)
└── cookpit.gyp/ # gyp configuration file for this project
```
