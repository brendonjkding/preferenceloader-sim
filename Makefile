DEBUG ?= 1
TARGET = simulator:clang:latest:8.0

LIBRARY_NAME = libprefs
libprefs_LOGOSFLAGS = -c generator=internal
libprefs_FILES = prefs.xm
libprefs_FRAMEWORKS = UIKit
libprefs_PRIVATE_FRAMEWORKS = Preferences
libprefs_CFLAGS = -I.
libprefs_COMPATIBILITY_VERSION = 2.2.0
libprefs_LIBRARY_VERSION = $(shell echo "$(THEOS_PACKAGE_BASE_VERSION)" | cut -d'~' -f1)
libprefs_LDFLAGS = -compatibility_version $($(THEOS_CURRENT_INSTANCE)_COMPATIBILITY_VERSION)
#libprefs_LDFLAGS += -current_version $($(THEOS_CURRENT_INSTANCE)_LIBRARY_VERSION)

TWEAK_NAME = PreferenceLoader
PreferenceLoader_FILES = Tweak.xm
PreferenceLoader_FRAMEWORKS = UIKit
PreferenceLoader_PRIVATE_FRAMEWORKS = Preferences
PreferenceLoader_LIBRARIES = prefs
PreferenceLoader_CFLAGS = -fobjc-arc -I.
PreferenceLoader_LDFLAGS = -L$(THEOS_OBJ_DIR)

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/tweak.mk

# Here, PreferenceLoader is expected to be linked against `$(THEOS_OBJ_DIR)/libprefs.dylib`,
# however a linker tries to use `$THEOS/vendor/lib/libprefs.tbd`,
# and it fails because `libprefs.tbd` in theos is not built for x86_64.
# This happens because theos internally set "$THEOS/vendor/lib" as a search dir,
# and `PreferenceLoader_LDFLAGS` has lower priority than that.
# In this hack, we force the linker to search `$THEOS_OBJ_DIR` first by setting `$TARGET_LD`.
TARGET_LD := $(TARGET_LD) -L$(THEOS_OBJ_DIR)

include locatesim.mk

SIMULATOR = 1

setup::
	#bundle & loader path (root)
	@[ -L $(PL_ROOT_BUNDLES_PATH) ] || sudo ln -s  $(PL_SIMJECT_BUNDLES_PATH)  $(PL_ROOT_BUNDLES_PATH)
	@[ -L $(PL_ROOT_PL_PATH) ] || sudo ln -s  $(PL_SIMJECT_PL_PATH) $(PL_ROOT_PL_PATH)

	#pref path
	@[ -d /var/mobile/Library/Preferences ] || sudo mkdir -p /var/mobile/Library/Preferences
	@sudo chmod -R 777 /var/mobile
	@[ -d /User ] || sudo ln -s /var/mobile /User || true
	@[ -d /User ] || echo -e "\x1b[1;35m>> warning: create symlink /User to /var/mobile manually if needed\x1b[m" || true

	#lib
	@[ -f $(SIMULATOR_ROOT)/usr/lib/$(LIBRARY_NAME).dylib ] || sudo ln -s $(PL_SIMJECT_ROOT)/usr/lib/$(LIBRARY_NAME).dylib $(SIMULATOR_ROOT)/usr/lib/$(LIBRARY_NAME).dylib || true
	@[ -f $(SIMULATOR_ROOT)/usr/lib/$(LIBRARY_NAME).dylib ] || echo -e "\x1b[1;35m>> warning: create symlink in $(SIMULATOR_ROOT)/usr/lib yourself \x1b[m" || true

remove::
	#bundle & loader path (root)
	@sudo rm -f $(PL_ROOT_BUNDLES_PATH) $(PL_ROOT_PL_PATH)
	@rm -f $(SIMULATOR_ROOT)/usr/lib/$(LIBRARY_NAME).dylib