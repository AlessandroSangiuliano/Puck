//
// PuckUIHandler
// Puck
//
// Created by slex on 28/05/21.
//

#import <Foundation/Foundation.h>
#import <XCBKit/XCBConnection.h>
#import "utils/PuckUtils.h"
#import "enums/EResize.h"

#define DOCKMASK  XCB_EVENT_MASK_STRUCTURE_NOTIFY | XCB_EVENT_MASK_PROPERTY_CHANGE
#define OFFSET 5

@interface PuckUIHandler : NSObject
{
}

@property (strong, nonatomic) XCBWindow *window;
@property (strong, nonatomic) XCBWindow *iconizedWindowsContainer;
@property (nonatomic, assign) xcb_window_t *clientList;
@property (strong, nonatomic) PuckUtils *puckUtils;
@property (strong, nonatomic) XCBConnection *connection;
@property (strong, nonatomic) NSMutableDictionary *iconizedWindows;

- (id) initWithConnection:(XCBConnection*) aConnection;
- (void) drawDock:(CGFloat)width andHeigth:(CGFloat)height;
- (void) addToIconizedWindows:(XCBWindow*)aWindow andResize:(Resize)aValue;
- (BOOL) inIconizedWindowsWithId:(xcb_window_t)winId;
- (void) removeFromIconizedWindows:(XCBWindow*)aWindow;
- (void) updateClientList;
- (void) resizeToPosition:(XCBPoint)aPosition andSize:(XCBSize)aSize;

@end