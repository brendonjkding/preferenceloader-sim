DEBUG ?= 1
TARGET = simulator:clang:11.2:8.0

include $(THEOS)/makefiles/common.mk

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

include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/tweak.mk

# Here, PreferenceLoader is expected to be linked against `$(THEOS_OBJ_DIR)/libprefs.dylib`,
# however a linker tries to use `$THEOS/vendor/lib/libprefs.tbd`,
# and it fails because `libprefs.tbd` in theos is not built for x86_64.
# This happens because theos internally set "$THEOS/vendor/lib" as a search dir,
# and `PreferenceLoader_LDFLAGS` has lower priority than that.
# In this hack, we force the linker to search `$THEOS_OBJ_DIR` first by setting `$TARGET_LD`.
TARGET_LD := $(TARGET_LD) -L$(THEOS_OBJ_DIR)

$(shell rm -f $(THEOS)/makefiles/locatesim.mk)
$(shell ln -s $(PWD)/locatesim.mk $(THEOS)/makefiles/locatesim.mk)

include locatesim.mk

setup:: all
	#bundle & loader path (sim)
	@[ -d $(PL_SIMULATOR_BUNDLES_PATH) ] || sudo mkdir -p $(PL_SIMULATOR_BUNDLES_PATH)
	@[ -d $(PL_SIMULATOR_PLISTS_PATH) ] || sudo mkdir -p $(PL_SIMULATOR_PLISTS_PATH)

	#bundle & loader path (root)
	@[ -d $(PL_ROOT_BUNDLES_PATH) ] || sudo ln -s  $(PL_SIMULATOR_BUNDLES_PATH)  $(PL_ROOT_BUNDLES_PATH)
	@[ -d $(PL_ROOT_PLISTS_PATH) ] || sudo ln -s  $(PL_SIMULATOR_PL_PATH) $(PL_ROOT_PL_PATH)

	#pref path
	@[ -d /var/mobile/Library/Preferences ] || sudo mkdir -p /var/mobile/Library/Preferences
	@sudo chmod -R 777 /var/mobile
	@[ -d /User ] || sudo ln -s /var/mobile /User || true
	@[ -d /User ] || echo -e "\x1b[1;35m>> warning: create symlink /User to /var/mobile manually if needed\x1b[m" || true

	#lib
	@[ -d $(PL_SIMULATOR_ROOT)/usr/lib ] || sudo mkdir -p $(PL_SIMULATOR_ROOT)/usr/lib
	@sudo rm -f $(PL_SIMULATOR_ROOT)/usr/lib/$(LIBRARY_NAME).dylib
	@sudo cp -v $(THEOS_OBJ_DIR)/$(LIBRARY_NAME).dylib $(PL_SIMULATOR_ROOT)/usr/lib
	@sudo codesign -f -s - $(PL_SIMULATOR_ROOT)/usr/lib/$(LIBRARY_NAME).dylib
	@[ -f /usr/lib/$(LIBRARY_NAME).dylib ] || sudo ln -s $(PL_SIMULATOR_ROOT)/usr/lib/$(LIBRARY_NAME).dylib /usr/lib/$(LIBRARY_NAME).dylib || true
	@[ -f /usr/lib/$(LIBRARY_NAME).dylib ] || echo -e "\x1b[1;35m>> warning: create symlink in /usr/lib yourself if needed\x1b[m" || true

	#tweak
	@rm -f /opt/simject/$(TWEAK_NAME).dylib
	@cp -v $(THEOS_OBJ_DIR)/$(TWEAK_NAME).dylib /opt/simject
	@sudo codesign -f -s - /opt/simject/$(TWEAK_NAME).dylib
	@cp -v $(PWD)/$(TWEAK_NAME).plist /opt/simject
	@resim

remove::
	#bundle & loader path (sim)
	@[ ! -d $(PL_SIMULATOR_BUNDLES_PATH) ] || sudo rm -d $(PL_SIMULATOR_BUNDLES_PATH) || true
	@[ ! -d $(PL_SIMULATOR_PLISTS_PATH) ] || sudo rm -d $(PL_SIMULATOR_PLISTS_PATH) || true
	#bundle & loader path (root)
	@sudo rm -f $(PL_ROOT_BUNDLES_PATH) $(PL_ROOT_PL_PATH)
	#lib
	@sudo rm -f $(PL_SIMULATOR_ROOT)/usr/lib/$(LIBRARY_NAME).dylib
	@sudo rm -f /usr/lib/$(LIBRARY_NAME).dylib
	#tweak
	@rm -f /opt/simject/$(TWEAK_NAME).dylib /opt/simject/$(TWEAK_NAME).plist
	@rm -f $(THEOS)/makefiles/locatesim.mk
	@resim
