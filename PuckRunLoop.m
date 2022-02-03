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
                NSLog(@"Window %u mapped", mapNotify->window);
                [eventHandler handleMapNotify:mapNotify];
                [connection flush];
                break;
            }
            case XCB_CREATE_NOTIFY:
            {
                xcb_create_notify_event_t *createEvent = (xcb_create_notify_event_t*) e;
                NSLog(@"Window %u created", createEvent->window);
                [eventHandler handleCreateNotify:createEvent];
                [connection flush];
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
            case XCB_DESTROY_NOTIFY:
            {
                xcb_destroy_notify_event_t *destroyNotify = (xcb_destroy_notify_event_t *) e;
                NSLog(@"Destroy EVENT for window: %u", destroyNotify->window);
                [eventHandler handleDestroyNotify:destroyNotify];
                [connection flush];
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