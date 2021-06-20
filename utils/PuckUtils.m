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
    
    //FIXME: free the reply;

    xcb_window_t *list = xcb_get_property_value(reply);
    clientListSize = xcb_get_property_value_length(reply) / 4;
    [connection flush];
    
    NSLog(@"Client size direct %d", clientListSize);
    
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
    
    clientListSize = xcb_get_property_value_length(reply) / 4;
    [connection flush];
    
    rootWindow = nil;

    return list;
}

- (void) encapsulateWindow:(xcb_window_t)aWindow
{
    NSNumber *key = [[NSNumber alloc] initWithInt:aWindow];

    XCBWindow *window = [[XCBWindow alloc] initWithXCBWindow:aWindow andConnection:connection];
    [[connection windowsMap] setObject:window forKey:key];
    

    window = nil;
    key = nil;
}

- (void) addListenerForWindow:(XCBWindow*)aWindow withMask:(uint32_t)aMask
{
    uint32_t val[] = {aMask};
    [aWindow changeAttributes:val withMask:XCB_CW_EVENT_MASK checked:NO];
}

- (void)dealloc
{
    connection = nil;
    ewmhService = nil;
}
@end