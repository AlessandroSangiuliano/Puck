//
// Boiler.h
// objc_boilers
//
// Created by slex on 21/08/21.
//

#import <Foundation/Foundation.h>
#import <UnitKit/FrameworkSource/UnitKit.h>
#import "../PuckUIHandler.h"
#import <XCBKit/XCBConnection.h>
#import <XCBKit/XCBWindow.h>
#import <XCBKit/XCBFrame.h>

@interface TestPuckUIHandler : NSObject <UKTest>
{
    UKTestHandler *handler;
    BOOL reportedStatus;
    XCBConnection *connection;
    XCBFrame *findingWindow;
    XCBFrame *fillingWindow0;
    XCBFrame *fillingWindow1;
    XCBFrame *fillingWindow2;
    XCBFrame *fillingWindow3;
    XCBFrame *fillingWindow4;
}

@property (strong, nonatomic) PuckUIHandler *uiHandler;

- (instancetype) init;

- (void) testTest:(int)num;

- (void) testCountFollowingWindowsForWindow;
- (void) testIsFollowedByAnotherWindow;
- (void) testMoveFollowingWindows;
- (void) testFnIndexOfWindow;
@end