//
// PuckRunLoop
// Puck
//
// Created by slex on 30/05/21.

#import "PuckRunLoop.h"
#import "PuckEventHandlerFactory.h"

@implementation PuckRunLoop

@synthesize uiHandler;

- (id)initWithUIHandler:(PuckUIHandler*)anUiHandler
{
    self = [super init];

    if (self == nil)
    {
        NSLog(@"Unable to init...");
        return nil;
    }

    uiHandler = anUiHandler;

    return self;
}

- (void) addListenerForWindow:(XCBWindow*)aWindow
{
    uint32_t val[] = {DOCKMASK};
    [aWindow changeAttributes:val withMask:XCB_CW_EVENT_MASK checked:NO];
}

- (void)startEventHandlerLoop
{
    xcb_generic_event_t *e;
    XCBConnection *connection = [uiHandler connection];
    PuckEventHandlerFactory *eventHandler = [[PuckEventHandlerFactory alloc] initWithConnection:connection andUiHandler:uiHandler];

    while ((e = xcb_wait_for_event([connection connection])))
    {
        switch (e->response_type & ~0x80)
        {
            case XCB_MAP_NOTIFY:
            {
                xcb_map_notify_event_t *mapNotify = (xcb_map_notify_event_t*) e;
                //NSLog(@"Window %u mapped", mapNotify->window);
                break;
            }
            case XCB_PROPERTY_NOTIFY:
            {
                xcb_property_notify_event_t *propEvent = (xcb_property_notify_event_t *) e;
                [eventHandler handlePropertyNotify:propEvent];
                [connection flush];
                break;
            }
            case XCB_MOTION_NOTIFY:
            {
                break;
            }
            default:
            {
                //NSLog(@"Default");
                break;
            }
        }
    }

    eventHandler = nil;
    connection = nil;
}

- (void) dealloc
{
    uiHandler = nil;
}

@end