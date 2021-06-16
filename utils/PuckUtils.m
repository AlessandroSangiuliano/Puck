//
// PuckUtils
// Puck
//
// Created by slex on 02/06/21.

#import "PuckUtils.h"

@implementation PuckUtils

@synthesize connection;
@synthesize ewmhService;
@synthesize clientListSize;

-(id)initWhitConnection:(XCBConnection*)aConnection
{
    self = [super init];

    if (self == nil)
    {
        NSLog(@"Unable to init...");
        return nil;
    }

    connection = aConnection;
    ewmhService = [EWMHService sharedInstanceWithConnection:connection];

    return self;
}

- (xcb_window_t*)queryForNetClientList
{
    XCBWindow *rootWindow = [connection rootWindowForScreenNumber:0];

    xcb_get_property_reply_t *reply = [ewmhService
                                       getProperty:[ewmhService EWMHClientList]
                                      propertyType:XCB_ATOM_WINDOW
                                         forWindow:rootWindow
                                            delete:NO
                                            length:UINT32_MAX];

    xcb_window_t *list = xcb_get_property_value(reply);
    [connection flush];

    for (int i = 0; list[i] != 0; i++)
        clientListSize = i + 1;

    rootWindow = nil;

    return list;
}

- (xcb_window_t*) queryForNetClientListStacking
{
    XCBWindow *rootWindow = [connection rootWindowForScreenNumber:0];

    xcb_get_property_reply_t *reply = [ewmhService
                                       getProperty:[ewmhService EWMHClientListStacking]
                                      propertyType:XCB_ATOM_WINDOW
                                         forWindow:rootWindow
                                            delete:NO
                                            length:UINT32_MAX];

    xcb_window_t *list = xcb_get_property_value(reply);
    [connection flush];

    for (int i = 0; list[i] != 0; i++)
        clientListSize = i + 1;


    rootWindow = nil;

    return list;
}

- (void) encapsulateWindow:(xcb_window_t)aWindow
{
    XCBWindow *window = [[XCBWindow alloc] initWithXCBWindow:aWindow andConnection:connection];

    NSNumber *key = [[NSNumber alloc] initWithInt:aWindow];
    [[connection windowsMap] setObject:window forKey:key];

    window = nil;
    key = nil;
}

- (void)dealloc
{
    connection = nil;
    ewmhService = nil;
}
@end