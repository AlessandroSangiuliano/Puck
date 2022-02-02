//
// PuckEventHandlerFactory
// Puck
//
// Created by slex on 05/06/21.
//

#import <Foundation/Foundation.h>
#import <XCBKit/XCBConnection.h>
#import "PuckUIHandler.h"

@interface PuckEventHandlerFactory : NSObject
{
}

@property (strong, nonatomic) XCBConnection* connection;
@property (strong, nonatomic) PuckUIHandler *uiHandler;
@property (assign, nonatomic) BOOL statusDestroy;

- (id)initWithConnection:(XCBConnection*)aConnection andUiHandler:(PuckUIHandler*)anUiHandler;

- (void) handlePropertyNotify:(xcb_property_notify_event_t*)anEvent;
- (void) handleDestroyNotify:(xcb_destroy_notify_event_t *)anEvent;
- (void) handleMapNotify:(xcb_map_notify_event_t*)anEvent;

@end