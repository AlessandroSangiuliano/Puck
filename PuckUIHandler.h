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

#define DOCKMASK  XCB_EVENT_MASK_STRUCTURE_NOTIFY | XCB_EVENT_MASK_PROPERTY_CHANGE | XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY
#define OFFSET 5

@interface PuckUIHandler : NSObject
{
}

@property (strong, nonatomic) XCBWindow *dockWindow;
@property (strong, nonatomic) XCBWindow *iconizedWindowsContainer;
@property (strong, nonatomic) XCBWindow *separatorWindow;
@property (nonatomic, assign) xcb_window_t *clientList;
@property (strong, nonatomic) PuckUtils *puckUtils;
@property (strong, nonatomic) XCBConnection *connection;
@property (strong, nonatomic) NSMutableArray *iconizedWindows;

- (instancetype) init;
- (id) initWithConnection:(XCBConnection*) aConnection;
- (void) drawDock:(CGFloat)width andHeigth:(CGFloat)height;
- (void) addToIconizedWindowsContainer:(XCBWindow*)aWindow;
- (BOOL) isIconizedInFirstOrLastPosition:(XCBWindow *)aWindow;
- (BOOL) isFollowedByAnotherWindow:(XCBWindow *)originWindow;
- (void) updateClientList;
- (void) resize:(BOOL)firstOrLastPos needResize:(BOOL)needResize withFrame:(XCBFrame*)aFrame;
- (void) resizeToPosition:(XCBPoint)aPosition andSize:(XCBSize)aSize resize:(Resize)aResize;
- (void) removeFromIconizedWindowsById:(xcb_window_t)winId;
- (XCBWindow*) windowFromIconizedById:(xcb_window_t)winId;
- (NSInteger) countFollowingWindowsForWindow:(XCBWindow *)aWindow;
- (void) moveFollowingWindows:(NSInteger) followingQuantity  forWindow:(XCBWindow *) originWindow;
- (void) moveWindow:(XCBWindow *)aWindow toPosition:(XCBPoint)aPosition;

@end