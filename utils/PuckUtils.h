//
// PuckUtils
// Puck
//
// Created by slex on 02/06/21.
//

#import <Foundation/Foundation.h>
#import <XCBKit/XCBConnection.h>
#import <XCBKit/services/EWMHService.h>

@interface PuckUtils : NSObject
{
}

@property (strong, nonatomic) XCBConnection *connection;
@property (strong, nonatomic) EWMHService *ewmhService;
@property (nonatomic, assign) int clientListSize;

- (id)initWhitConnection:(XCBConnection*)aConnection;
- (xcb_window_t*)queryForNetClientList;
- (xcb_window_t*) queryForNetClientListStacking;
- (void) encapsulateWindow:(xcb_window_t)aWindow;
- (void) addListenerForWindow:(XCBWindow*)aWindow withMask:(uint32_t)aMask;

@end