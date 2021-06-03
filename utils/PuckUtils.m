//
// PuckUtils
// Puck
//
// Created by slex on 02/06/21.

#import "PuckUtils.h"

@implementation PuckUtils

@synthesize connection;
@synthesize ewmhService;

-(id)initWhitConnection:(XCBConnection*)aConnection
{
    self = [super init];

    if (self == nil)
    {
        NSLog(@"Unable to init...");
        return nil;
    }

    connection = aConnection;
    //ewmhService = [EWMHService sharedInstanceWithConnection:connection];

    return self;
}

- (xcb_window_t*)queryForNetClientList
{

    XCBWindow *rootWindow = [connection rootWindowForScreenNumber:0];

    XCBAtomService *atomService = [XCBAtomService sharedInstanceWithConnection:connection];

    xcb_get_property_cookie_t cookie = xcb_get_property([connection connection],
                                                        NO,
                                                        [rootWindow window],
                                                        [atomService atomFromCachedAtomsWithKey:@"_NET_CLIENT_LIST"],
                                                        XCB_ATOM_WINDOW,
                                                        0,
                                                        CLIENTLISTSIZE);

    xcb_get_property_reply_t *reply = xcb_get_property_reply([connection connection], cookie, NULL);

    xcb_window_t *list = xcb_get_property_value(reply);
    int size = xcb_get_property_value_length(reply);
    NSLog(@"List size: %d", size);

    rootWindow = nil;

    return list;
}

- (xcb_window_t*) queryForNetClientListStacking
{
    /*XCBWindow *rootWindow = [connection rootWindowForScreenNumber:0];

    xcb_get_property_reply_t *reply = [ewmhService
                                       getProperty:[ewmhService EWMHClientListStacking]
                                      propertyType:XCB_ATOM_WINDOW
                                         forWindow:rootWindow
                                            delete:NO
                                            length:UINT32_MAX];

    xcb_window_t *list = xcb_get_property_value(reply);
    int size = xcb_get_property_value_length(reply);
    NSLog(@"List size: %d", size);

    rootWindow = nil;*/

    return NULL;
}

- (void)dealloc
{
    connection = nil;
    ewmhService = nil;
}
@end