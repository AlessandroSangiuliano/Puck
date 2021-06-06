//
// PuckEventHandlerFactory
// Puck
//
// Created by slex on 05/06/21.
//

#import <Foundation/Foundation.h>
#import <XCBKit/XCBConnection.h>

@interface PuckEventHandlerFactory : NSObject
{
}

@property (strong, nonatomic) XCBConnection* connection;

- (id)initWithConnection:(XCBConnection*)aConnection;

- (void) handlePropertyNotify:(xcb_property_notify_event_t*)anEvent;

@end