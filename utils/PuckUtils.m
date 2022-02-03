//
// PuckUtils
// Puck
//
// Created by slex on 02/06/21.

#import "PuckUtils.h"
#import "XCBKit/XCBFrame.h"
#import "XCBKit/XCBTitleBar.h"

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
    
    if (reply)
        clientListSize = xcb_get_property_value_length(reply) / 4;

    xcb_window_t *list = (xcb_window_t*) malloc(clientListSize * sizeof(xcb_window_t));
    xcb_window_t *aux = xcb_get_property_value(reply);
    
    for (int i = 0; i < clientListSize; ++i)
        list[i] = aux[i];
    
    
    [connection flush];
    
    NSLog(@"Client size direct %d", clientListSize);
    
    rootWindow = nil;
    free(reply);

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
    
    if (reply)
        clientListSize = xcb_get_property_value_length(reply) / 4; // 4 are the bytes for an int...
    
    xcb_window_t *list = (xcb_window_t*) malloc(clientListSize * sizeof(xcb_window_t));
    xcb_window_t *aux = xcb_get_property_value(reply);
    
    for (int i = 0; i < clientListSize; ++i)
        list[i] = aux[i];
    
    [connection flush];
    
    rootWindow = nil;

    return list;
}

- (void) encapsulateWindow:(xcb_window_t)aWindow
{
    XCBWindow *window = [[XCBWindow alloc] initWithXCBWindow:aWindow andConnection:connection];
    XCBWindow *frame = [[window queryTree] parentWindow];
    
    [window setParentWindow:frame];
    [self registerWindow:window];

    window = nil;
    frame = nil;
}

- (void) addListenerForWindow:(XCBWindow*)aWindow withMask:(uint32_t)aMask
{
    uint32_t val[] = {aMask};
    [aWindow changeAttributes:val withMask:XCB_CW_EVENT_MASK checked:NO];
}

- (void)registerWindow:(XCBWindow *)aWindow
{
    if ([aWindow isKindOfClass:[XCBTitleBar class]] ||
            [aWindow isMinimizeButton] ||
            [aWindow isMaximizeButton] ||
            [aWindow isCloseButton] ||
            [aWindow isKindOfClass:[XCBFrame class]])
    {
        NSLog(@"Not a client window. Need one of them to be registered.");
        return;
    }
    
    
    NSNumber *key = [NSNumber numberWithUnsignedInt:[aWindow window]];
    [[connection windowsMap] setObject:aWindow forKey:key];
    
    key = nil;
}

- (void)unregisterWindow:(XCBWindow *)aWindow
{
    NSNumber *key = [NSNumber numberWithUnsignedInt:[aWindow window]];
    [[connection windowsMap] removeObjectForKey:key];
    
    key = nil;
}


- (void)dealloc
{
    connection = nil;
    ewmhService = nil;
}
@end