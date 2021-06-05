//
// PuckEventHandler
// Puck
//
// Created by slex on 30/05/21.
//

#import <Foundation/Foundation.h>
#import <XCBKit/XCBConnection.h>
#import "PuckUIHandler.h"

@interface PuckEventHandler : NSObject
{
}

@property (strong, nonatomic) PuckUIHandler *uiHandler;

- (id) initWithUIHandler:(PuckUIHandler*)anUiHandler;

- (void) handlePropertyNotify:(xcb_property_notify_event_t*)anEvent;
- (void) startEventHandlerLoop;

@end