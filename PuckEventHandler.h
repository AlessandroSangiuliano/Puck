//
// PuckEventHandler
// Puck
//
// Created by slex on 30/05/21.
//

#import <Foundation/Foundation.h>
#import <XCBKit/XCBConnection.h>

@interface PuckEventHandler : XCBConnection
{
}

- (id) init;

- (void) handlePropertyNotify:(xcb_property_notify_event_t*)anEvent;
- (void) startEventHandlerLoop;

@end