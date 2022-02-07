//
// EncapsulatedWindow
// Puck
//
// Created by slex on 05/02/22.
//

#import <Foundation/Foundation.h>
#import "XCBKit/XCBWindow.h"

@interface EncapsulatedWindow : NSObject
{
}

@property (strong, nonatomic) XCBWindow *window;
@property (assign, nonatomic) xcb_window_t *children;
@property (assign, nonatomic) int childrenLen;

- (instancetype) init;

@end