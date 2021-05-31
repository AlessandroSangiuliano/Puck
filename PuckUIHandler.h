//
// PuckUIHandler
// Puck
//
// Created by slex on 28/05/21.
//

#import <Foundation/Foundation.h>
#import <XCBKit/XCBConnection.h>
#import "PuckEventHandler.h"

#define DOCKMASK XCB_EVENT_MASK_PROPERTY_CHANGE | XCB_EVENT_MASK_STRUCTURE_NOTIFY

@interface PuckUIHandler : NSObject
{
}

@property (strong, nonatomic) PuckEventHandler *eventHandler;
@property (strong, nonatomic) XCBWindow *window;

- (id) initWithEventHandler:(PuckEventHandler*) anEventHandler;
- (void) drawDock:(CGFloat)width andHeigth:(CGFloat)height;

@end