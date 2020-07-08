# fallback to 9.3 here
PL_SIMULATOR_VERSION := 9.3

PL_XCODE_VERSION := $(shell xcodebuild -version | sed -nE 's/Xcode +([0-9]+)\..*/\1/p')
ifeq ($(shell [ $(PL_XCODE_VERSION) -ge 11 ]; echo $$?),0)
# for Xcode 11 or later
PL_SIMULATOR_ROOT = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot

else ifeq ($(shell [ $(PL_XCODE_VERSION) -ge 9 ]; echo $$?),0)
# for Xcode 9-10
PL_SIMULATOR_ROOT = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot

else
# for Xcode 8 or earlier
PL_SIMULATOR_ROOT = /Library/Developer/CoreSimulator/Profiles/Runtimes/iOS\ $(PL_SIMULATOR_VERSION).simruntime/Contents/Resources/RuntimeRoot
endif

PL_ROOT=

PL_SIMULATOR_BUNDLES_PATH = $(PL_SIMULATOR_ROOT)/Library/PreferenceBundles
PL_SIMULATOR_PLISTS_PATH = $(PL_SIMULATOR_ROOT)/Library/PreferenceLoader/Preferences
PL_SIMULATOR_PL_PATH = $(PL_SIMULATOR_ROOT)/Library/PreferenceLoader

PL_ROOT_BUNDLES_PATH = $(PL_ROOT)/Library/PreferenceBundles
PL_ROOT_PLISTS_PATH = $(PL_ROOT)/Library/PreferenceLoader/Preferences
PL_ROOT_PL_PATH = $(PL_ROOT)/Library/PreferenceLoader

MS_SIMULATOR_BUNDLES_PATH = $(PL_SIMULATOR_ROOT)/Library/MenuSupport/Plugins