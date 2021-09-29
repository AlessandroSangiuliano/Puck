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

@interface TestPuckUIHandler : NSObject <UKTest>
{
    UKTestHandler *handler;
    BOOL reportedStatus;
    XCBConnection *connection;
    XCBWindow *findingWindow;
    XCBWindow *fillingWindow0;
    XCBWindow *fillingWindow1;
    XCBWindow *fillingWindow2;
    XCBWindow *fillingWindow3;
    XCBWindow *fillingWindow4;
}

@property (strong, nonatomic) PuckUIHandler *uiHandler;

- (instancetype) init;

- (void) testTest:(int)num;

- (void) testCountFollowingWindowsForWindow;
- (void) testIsFollowedByAnotherWindow;
@end