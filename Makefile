DEBUG = 1
TARGET = simulator:clang:latest:8.0

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
PreferenceLoader_CFLAGS = -I.
PreferenceLoader_LDFLAGS = -L$(THEOS_OBJ_DIR)

include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/tweak.mk

include locatesim.mk

setup:: all
	@[ -d $(PL_SIMULATOR_BUNDLES_PATH) ] || sudo mkdir -p $(PL_SIMULATOR_BUNDLES_PATH)
	@[ -d $(PL_SIMULATOR_PLISTS_PATH) ] || sudo mkdir -p $(PL_SIMULATOR_PLISTS_PATH)
	@[ -d $(PL_SIMULATOR_PLISTS_PATH)/usr/lib ] || sudo mkdir -p $(PL_SIMULATOR_ROOT)/usr/lib
	@sudo cp -v $(THEOS_OBJ_DIR)/$(LIBRARY_NAME).dylib $(PL_SIMULATOR_ROOT)/usr/lib
	@rm -f /opt/simject/$(TWEAK_NAME).dylib
	@cp -v $(THEOS_OBJ_DIR)/$(TWEAK_NAME).dylib /opt/simject
	@cp -v $(PWD)/$(TWEAK_NAME).plist /opt/simject

remove::
	@[ ! -d $(PL_SIMULATOR_BUNDLES_PATH) ] || sudo rm -r $(PL_SIMULATOR_BUNDLES_PATH)
	@[ ! -d $(PL_SIMULATOR_PLISTS_PATH) ] || sudo rm -r $(PL_SIMULATOR_PLISTS_PATH)
	@sudo rm -f $(PL_SIMULATOR_ROOT)/usr/lib/$(LIBRARY_NAME).dylib
	@rm -f /opt/simject/$(TWEAK_NAME).dylib /opt/simject/$(TWEAK_NAME).plist
