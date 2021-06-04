//
// PuckEventHandler
// Puck
//
// Created by slex on 30/05/21.

#import "PuckEventHandler.h"
#import <XCBKit/services/ICCCMService.h>

@implementation PuckEventHandler

@synthesize connection;

- (id)init
{
    self = [super init];

    if (self == nil)
    {
        NSLog(@"Unable to init...");
        return nil;
    }

    connection = [[XCBConnection alloc] initAsWindowManager:NO];

    return self;
}

- (void)handlePropertyNotify:(xcb_property_notify_event_t*)anEvent
{
    NSLog(@"Window iconified with id: %u", anEvent->window);
}

- (void)startEventHandlerLoop
{
    xcb_generic_event_t *e;

    while ((e = xcb_wait_for_event([connection connection])))
    {
        NSLog(@"Event: %d", e->response_type);
        switch (e->response_type & ~0x80)
        {
            case XCB_PROPERTY_NOTIFY:
            {
                NSLog(@"In property event finally");
                xcb_property_notify_event_t *propEvent = (xcb_property_notify_event_t *) e;
                [self handlePropertyNotify:propEvent];
                [connection flush];
                break;
            }
            case XCB_MOTION_NOTIFY:
            {
                //NSLog(@"PENE");
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
    connection = nil;
}

@end