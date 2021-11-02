include $(GNUSTEP_MAKEFILES)/common.make

VERSION = 0.0.0

DEPENDENCIES = Puck
BUNDLE_NAME = TestPuck
export BUNDLE_NAME
$(BUNDLE_NAME)_APPLICATION_ICON =

$(BUNDLE_NAME)_LD_FLAGS += -LPuckUIHandler

$(BUNDLE_NAME)_NEEDS_GUI = no

$(BUNDLE_NAME)_OBJC_FILES = $(wildcard *.m) \
	$(filter-out ../main.m, $(wildcard ../*.m)) \
	$(wildcard ../utils/*.m) \
	$(wildcard ../functions/*.m)

$(BUNDLE_NAME)_HEADER_FILES = $(wildcard *.h) \
	$(wildcard ../*.h) \
	$(wildcard ../utils/*.h) \
	$(wildcard ../functions/*.h)

$(BUNDLE_NAME)_TOOL_LIBS = -lxcb -lXCBKit #-lPuck #-lXCBKit

ADDITIONAL_OBJCFLAGS = -std=c99 -g -O0 -fobjc-arc -Wall #-Wno-unused -Werror -Wall

#LIBRARIES_DEPEND_UPON += $(shell pkg-config --libs xcb) $(FND_LIBS) $(OBJC_LIBS) $(SYSTEM_LIBS)

include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/bundle.make
