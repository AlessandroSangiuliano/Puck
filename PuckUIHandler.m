//
// PuckUIHandler
// Puck
//
// Created by slex on 28/05/21.

#import "PuckUIHandler.h"


@implementation PuckUIHandler

@synthesize window;
@synthesize clientList;
@synthesize puckUtils;
@synthesize connection;
@synthesize iconizedWindowsArray;
@synthesize iconizedWindowsContainer;

- (id)initWithConnection:(XCBConnection*)aConnection
{
    self = [super init];

    if (self == nil)
    {
        NSLog(@"Unable to init...");
        return nil;
    }

    connection = aConnection;
    puckUtils = [[PuckUtils alloc] initWhitConnection:connection];

    clientList = [puckUtils queryForNetClientList]; /** we have clientList in the connection too. it could be reused **/

    iconizedWindowsArray = [[NSMutableArray alloc] init];

    return self;
}

- (void)drawDock:(CGFloat)width andHeigth:(CGFloat)height
{
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    XCBWindow *rootWindow = [screen rootWindow];

    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];

    uint32_t values[] = {[screen screen]->white_pixel, FRAMEMASK};

    XCBCreateWindowTypeRequest *request = [[XCBCreateWindowTypeRequest alloc] initForWindowType:XCBWindowRequest];

    [request setParentWindow:rootWindow];
    [request setDepth:[screen screen]->root_depth];
    [request setXPosition:[screen width] / 2 - width / 2];
    [request setYPosition:[screen height] - height];
    [request setWidth:width];
    [request setHeight:height];
    [request setBorderWidth:0];
    [request setXcbClass:XCB_WINDOW_CLASS_INPUT_OUTPUT];
    [request setValueMask:XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK];
    [request setValueList:values];

    XCBWindowTypeResponse *response = [connection createWindowForRequest:request registerWindow:NO];
    window = [response window];
    values[0] = 1;
    values[1] = 0;

    [window changeAttributes:values withMask:XCB_CW_OVERRIDE_REDIRECT checked:NO];
    uint32_t val[] = {DOCKMASK};
    [rootWindow changeAttributes:val withMask:XCB_CW_EVENT_MASK checked:NO];

    /*** Request for the iconized windows container ***/

    [request setParentWindow:window];
    [request setXPosition:width - 50];
    [request setYPosition:height - 75];
    [request setWidth:width];
    [request setHeight:height];

    values[0] = [screen screen]->white_pixel;
    values[1] = FRAMEMASK;

    response = [connection createWindowForRequest:request registerWindow:NO];

    iconizedWindowsContainer = [response window];

    [connection mapWindow:window];
    [connection mapWindow:iconizedWindowsContainer];
    [connection flush];

    screen = nil;
    request = nil;
    response = nil;
    visual = nil;
    rootWindow = nil;
}

- (void)dealloc
{
    connection = nil;
    window = nil;
    iconizedWindowsContainer = nil;
    iconizedWindowsArray = nil;
    puckUtils = nil;

    if (clientList)
        free(clientList); // is pure C, but inside there are unsigned int values
}

@end