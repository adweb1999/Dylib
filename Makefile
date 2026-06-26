THEOS_DEVICE_IP = 192.168.1.1
ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:14.0

# Build as dylib (not tweak)
include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = OneStateMod

OneStateMod_FILES = $(wildcard *.mm) $(wildcard imgui/*.cpp) $(wildcard imgui/*.mm)
OneStateMod_CFLAGS = -fobjc-arc -std=c++17 -O2
OneStateMod_LDFLAGS = -framework Foundation -framework UIKit -framework Metal -framework MetalKit -framework QuartzCore -framework CoreGraphics -framework Security -lobjc -lc++
OneStateMod_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/library.mk

# After build, copy dylib to root
after-all::
	@echo "========================================="
	@echo "  Build Complete!"
	@echo "  Output: $(THEOS_OBJ_DIR)/OneStateMod.dylib"
	@echo "========================================="
