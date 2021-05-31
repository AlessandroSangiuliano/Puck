//
// PuckUIHandler
// Puck
//
// Created by slex on 28/05/21.

#import "PuckUIHandler.h"
#import <XCBKit/utils/XCBCreateWindowTypeRequest.h>
#import <XCBKit/utils/XCBWindowTypeResponse.h>

@implementation PuckUIHandler

@synthesize eventHandler;
@synthesize window;

- (id)initWithEventHandler:(PuckEventHandler*)anEventHandler
{
    self = [super init];

    if (self == nil)
    {
        NSLog(@"Unable to init...");
        return nil;
    }

    eventHandler = anEventHandler;
    return self;

}

- (void)drawDock:(CGFloat)width andHeigth:(CGFloat)height
{
    XCBScreen *screen = [[eventHandler screens] objectAtIndex:0];
    XCBCreateWindowTypeRequest *request = [[XCBCreateWindowTypeRequest alloc] initForWindowType:XCBWindowRequest];

    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];

    uint32_t values[] = {[screen screen]->white_pixel, DOCKMASK};

    [request setParentWindow:[screen rootWindow]];
    [request setDepth:[screen screen]->root_depth];
    [request setXPosition:[screen width] / 2 - width / 2];
    [request setYPosition:[screen height] - height];
    [request setWidth:width];
    [request setHeight:height];
    [request setBorderWidth:0];
    [request setXcbClass:XCB_WINDOW_CLASS_INPUT_OUTPUT];
    [request setValueMask:XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK];
    [request setValueList:values];

    XCBWindowTypeResponse *response = [eventHandler createWindowForRequest:request registerWindow:YES];
    window = [response window];
    values[0] = 1;
    values[1] = 0;

    [window changeAttributes:values withMask:XCB_CW_OVERRIDE_REDIRECT checked:NO];

    [eventHandler mapWindow:window];
    [eventHandler flush];

    screen = nil;
    request = nil;
    response = nil;
    visual = nil;

}

- (void)dealloc
{
    eventHandler = nil;
    window = nil;
}

@end