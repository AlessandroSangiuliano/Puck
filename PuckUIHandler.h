//
// PuckUIHandler
// Puck
//
// Created by slex on 28/05/21.
//

#import <Foundation/Foundation.h>
#import <XCBKit/XCBConnection.h>
#import "utils/PuckUtils.h"

#define DOCKMASK  XCB_EVENT_MASK_STRUCTURE_NOTIFY | XCB_EVENT_MASK_PROPERTY_CHANGE

@interface PuckUIHandler : NSObject
{
}

@property (strong, nonatomic) XCBWindow *window;
@property (nonatomic, assign) xcb_window_t *clientList;
@property (strong, nonatomic) PuckUtils *puckUtils;
@property (strong, nonatomic) XCBConnection *connection;

- (id) initWithConnection:(XCBConnection*) aConnection;
- (void) drawDock:(CGFloat)width andHeigth:(CGFloat)height;

@end