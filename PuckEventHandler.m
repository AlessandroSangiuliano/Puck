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

}

- (void) dealloc
{

}

@end