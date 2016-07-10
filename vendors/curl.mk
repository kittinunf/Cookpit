include $(CLEAR_VARS)

LOCAL_MODULE := curl
LOCAL_SRC_FILES := vendors/curl/android/bin/$(TARGET_ARCH_ABI)/libcurl.a

include $(PREBUILT_STATIC_LIBRARY)
