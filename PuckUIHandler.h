//
// PuckUIHandler
// Puck
//
// Created by slex on 28/05/21.
//

#import <Foundation/Foundation.h>
#import <XCBKit/XCBConnection.h>

@interface PuckUIHandler : NSObject
{
}

@property (strong, nonatomic) XCBConnection *connection;
@property (strong, nonatomic) XCBWindow *window;

- (id) init;
- (void) drawDock:(CGFloat)width andHeigth:(CGFloat)height;
@end