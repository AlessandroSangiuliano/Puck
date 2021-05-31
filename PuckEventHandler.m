//
// PuckEventHandler
// Puck
//
// Created by slex on 30/05/21.

#import "PuckEventHandler.h"

@implementation PuckEventHandler

- (id)init
{
    self = [super init];

    if (self == nil)
    {
        NSLog(@"Unable to init...");
        return nil;
    }

    return self;
}

- (void)handlePropertyNotify:(xcb_property_notify_event_t*)anEvent
{
    NSLog(@"Window iconified with id: %u", anEvent->window);
}

- (void)startEventHandlerLoop
{
    xcb_generic_event_t *e;

    while ((e = xcb_wait_for_event([super connection])))
    {
        NSLog(@"Event: %d", e->response_type);
        switch (e->response_type & ~0x80)
        {
            case XCB_PROPERTY_NOTIFY:
            {
                NSLog(@"In property event finally");
                xcb_property_notify_event_t *propEvent = (xcb_property_notify_event_t *) e;
                [self handlePropertyNotify:propEvent];
                [super flush];
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

}

@end