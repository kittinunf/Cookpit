FORCE_GYP := $(shell make -C ../../../ GypAndroid.mk)
include ../../../GypAndroid.mk
include ../../../vendors/curl.mk
