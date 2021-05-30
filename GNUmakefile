PACKAGE_NAME = Puck

include $(GNUSTEP_MAKEFILES)/common.make

VERSION = 0.0.0

DEPENDENCIES = XCBKit

TOOL_NAME = Puck
export TOOL_NAME
$(TOOL_NAME)_APPLICATION_ICON =

$(TOOL_NAME)_LD_FLAGS += -L./XCBKit/XCBKit.framkework/

$(TOOL_NAME)_OBJC_FILES = \
		main.m \
		PuckUIHandler.m \
		PuckEventHandler.m \

$(TOOL_NAME)_HEADER_FILES = \
		PuckUIHandler.h \
		PuckEventHandler.h \

$(TOOL_NAME)_TOOL_LIBS = -lXCBKit -lxcb

ADDITIONAL_OBJCFLAGS = -std=c99 -g -O0 -fobjc-arc -Wall #-Wno-unused -Werror -Wall

#LIBRARIES_DEPEND_UPON += $(shell pkg-config --libs xcb) $(FND_LIBS) $(OBJC_LIBS) $(SYSTEM_LIBS)

include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/tool.make
