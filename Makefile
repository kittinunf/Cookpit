NAME = cookpit
LIB_ANDROID = lib$(NAME)_android
LIB_IOS = lib$(NAME)_ios
ARCH = armeabi-v7a,x86

all: lib ios android

clean:
	rm -rf build/
	rm -rf cpp/src/gen/
	rm -rf ios/objc_gen/
	rm -rf ios/$(NAME).xcodeproj
	rm -rf ios/vendors/
	rm -rf mac/objc_gen/
	rm -rf mac/$(NAME).xcodeproj
	rm -rf mac/vendors/
	rm -rf android/java_gen/
	rm -rf android/jni_gen/
	rm -rf android/$(NAME)/libs/
	rm -rf android/$(NAME)/obj/
	rm -rf cpp/vendors/
	rm -f GypAndroid.mk
	rm -f lib*.mk
	rm -f vendors/*.target.mk

ios: _build_ios
	xcodebuild -project ios/$(NAME).xcodeproj -configuration Release -target $(LIB_IOS) | ${xb-prettifier}

_build_ios: _djinni
	PYTHONPATH=vendors/gyp/pylib vendors/gyp/gyp -DOS=ios --depth=. -f xcode --generator-output ./ios -Icommon.gypi $(NAME).gyp

android: _build_android
	cd android/$(NAME) && ./gradlew app:ndkBuild -Darch=$(ARCH) && cd ../..

_build_android: _djinni
	ANDROID_BUILD_TOP=dirname PYTHONPATH=vendors/gyp/pylib $(which ndk-build) vendors/gyp/gyp --depth=. -f android -DOS=android --root-target $(LIB_ANDROID) -Icommon.gypi $(NAME).gyp

lib: _build_lib
	xcodebuild -project cpp/$(NAME).xcodeproj -configuration Release -target $(LIB_IOS) | ${xb-prettifier}

_build_lib: _djinni
	PYTHONPATH=vendors/gyp/pylib vendors/gyp/gyp -DOS=lib --depth=. -f xcode --generator-output ./cpp -Icommon.gypi $(NAME).gyp

test: _djinni
	xcodebuild -project cpp/$(NAME).xcodeproj -configuration Debug TEST_MODE=1 -target test  | ${xb-prettifier} && ./build/Debug/test

_djinni:
	./utils/run_djinni

xb-prettifier := $(shell command -v xcpretty >/dev/null 2>&1 && echo "xcpretty -c" || echo "cat")
