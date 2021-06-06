//
// PuckEventHandlerFactory
// Puck
//
// Created by slex on 05/06/21.

#import "PuckEventHandlerFactory.h"
#import <XCBKit/services/XCBAtomService.h>

@implementation PuckEventHandlerFactory

@synthesize connection;

- (id)initWithConnection:(XCBConnection*)aConnection
{
    self = [super init];

    if (self == nil)
    {
        NSLog(@"Unable to init...");
        return nil;
    }

    connection = aConnection;

    return self;
}

- (void)handlePropertyNotify:(xcb_property_notify_event_t*)anEvent
{
    XCBAtomService *atomService = [XCBAtomService sharedInstanceWithConnection:connection];
    NSString *name = [atomService atomNameFromAtom:anEvent->atom];
    NSLog(@"Aton name: %@", name);

    atomService = nil;
}

- (void)dealloc
{
    connection = nil;
}

@end