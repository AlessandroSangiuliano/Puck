//
// PuckEventHandler
// Puck
//
// Created by slex on 30/05/21.

#import "PuckEventHandler.h"

@implementation PuckEventHandler

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

- (void)handlePropertyNotify:(xcb_property_notify_event_t*)anEvent
{
    XCBAtomService *atomService = [XCBAtomService sharedInstanceWithConnection:connection];
    NSString *name = [atomService atomNameFromAtom:anEvent->atom];
    NSLog(@"Aton name: %@", name);
}

- (void)startEventHandlerLoop
{
    xcb_generic_event_t *e;

    while ((e = xcb_wait_for_event([connection connection])))
    {
        switch (e->response_type & ~0x80)
        {
            case XCB_MAP_NOTIFY:
            {
                xcb_map_notify_event_t *mapNotify = (xcb_map_notify_event_t*) e;
                NSLog(@"Window %u mapped", mapNotify->window);
                break;
            }
            case XCB_PROPERTY_NOTIFY:
            {
                xcb_property_notify_event_t *propEvent = (xcb_property_notify_event_t *) e;
                [self handlePropertyNotify:propEvent];
                [connection flush];
                break;
            }
            case XCB_MOTION_NOTIFY:
            {
                break;
            }
            default:
            {
                NSLog(@"Default");
                break;
            }
        }
    }
}

- (void) dealloc
{
    uiHandler = nil;
}

@end