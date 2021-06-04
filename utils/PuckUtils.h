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

@end