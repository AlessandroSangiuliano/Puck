//
// Functions.h
// Puck
//
// Created by slex on 01/11/21.
//

#import <Foundation/Foundation.h>
#import <XCBKit/XCBWindow.h>
#import <XCBKit/utils/XCBShape.h>

XCBPoint FnCalculateNewPosition(XCBWindow *movingWindow, int offset);
NSInteger FnIndexOfWindow(NSMutableArray *anArray, XCBWindow *searchingWindow);