//
// Boiler
// objc_boilers
//
// Created by slex on 21/08/21.

#import "TestPuckUIHandler.h"
#import "../functions/Functions.h"

@implementation TestPuckUIHandler

@synthesize uiHandler;

- (instancetype)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
    handler = [UKTestHandler handler];
    [handler setDelegate:self];
    connection = [[XCBConnection alloc] initAsWindowManager:NO];
    uiHandler = [[PuckUIHandler alloc] init];
    
    findingWindow = [[XCBFrame alloc] initWithXCBWindow:1002 andConnection:connection];
    
    fillingWindow0 = [[XCBFrame alloc] initWithXCBWindow:1000 andConnection:connection];
    fillingWindow1 = [[XCBFrame alloc] initWithXCBWindow:1001 andConnection:connection];
    fillingWindow2 = [[XCBFrame alloc] initWithXCBWindow:1002 andConnection:connection];
    fillingWindow3 = [[XCBFrame alloc] initWithXCBWindow:1003 andConnection:connection];
    fillingWindow4 = [[XCBFrame alloc] initWithXCBWindow:1004 andConnection:connection];
    
    XCBRect rect0 = XCBMakeRect(XCBMakePoint(0, 0), XCBMakeSize(50, 50));
    XCBRect rect1 = XCBMakeRect(XCBMakePoint(50 + OFFSET * 2 + 3, 0), XCBMakeSize(50, 50));
    XCBRect rect2 = XCBMakeRect(XCBMakePoint(100 + OFFSET * 2 + 3, 0), XCBMakeSize(50, 50));
    XCBRect rect3 = XCBMakeRect(XCBMakePoint(150 + OFFSET * 2 + 3, 0), XCBMakeSize(50, 50));
    XCBRect rect4 = XCBMakeRect(XCBMakePoint(200 + OFFSET * 2 + 3, 0), XCBMakeSize(50, 50));
    
    [fillingWindow0 setWindowRect:rect0];
    [fillingWindow1 setWindowRect:rect1];
    [fillingWindow2 setWindowRect:rect2];
    [fillingWindow3 setWindowRect:rect3];
    [fillingWindow4 setWindowRect:rect4];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [uiHandler setIconizedWindows:array];
    
    [[uiHandler iconizedWindows] addObject:fillingWindow0];
    [[uiHandler iconizedWindows] addObject:fillingWindow1];
    [[uiHandler iconizedWindows] addObject:fillingWindow2];
    [[uiHandler iconizedWindows] addObject:fillingWindow3];
    [[uiHandler iconizedWindows] addObject:fillingWindow4];
    
    array = nil;
    
    return self;
}

- (void)reportStatus: (BOOL)cond inFile: (char *)filename line: (int)line message: (NSString *)msg
{
    reportedStatus = cond;
}

- (void)testTest:(int)num
{
    UKTrue(5 > 4);
    
    NSInteger index = [[uiHandler iconizedWindows] indexOfObject:fillingWindow1];
    
    NSLog(@"Position %ld", index);
    
    handler.delegate = nil;
    NSAssert(reportedStatus, @"Failsafe check on UKTrue");
    UKTrue(reportedStatus);
}

- (void)testCountFollowingWindowsForWindow
{
    NSInteger value = [uiHandler countFollowingWindowsForWindow:findingWindow];
    NSInteger expectedValue = 2;
    
    UKIntsEqual(value, expectedValue);
    handler.delegate = nil;
    NSAssert(reportedStatus, @"Failsafe check on UKIntsEqual"); //necessario?
    UKTrue(reportedStatus);
    
}

- (void)testIsFollowedByAnotherWindow
{
    BOOL followed = [uiHandler isFollowedByAnotherWindow:findingWindow];
    UKTrue(followed);
    [handler setDelegate:nil];
    NSAssert(reportedStatus, @"No window is following!");
    UKTrue(reportedStatus);
}

- (void)testMoveFollowingWindows
{
    NSInteger following = [uiHandler countFollowingWindowsForWindow:fillingWindow2];
    NSInteger winPosition = [[uiHandler iconizedWindows] indexOfObject:fillingWindow2];
    
    for (int i = 0; i < following; ++i)
    {
        winPosition++;
        XCBWindow *movingWindow = [[uiHandler iconizedWindows] objectAtIndex:winPosition];
        XCBPoint newPosition = FnCalculateNewPosition(movingWindow, OFFSET);
        XCBRect newRect = XCBMakeRect(newPosition, [movingWindow windowRect].size);
        
        /*** instead to call [moving moveTo:] the needs X11 and the dockbar running,
         *  we mock the behavior with effectively calling xcb_configure_window that would segfault;
         *  so just setting the rect as [frame moveTo:] would do.
         */
         
        [movingWindow setWindowRect:newRect];
        movingWindow = nil;
    }
    
    double expected3 = 100;
    double expected4 = 150;
    
    UKFloatsEqual(expected3, [fillingWindow3 windowRect].position.x, 0);
    UKFloatsEqual(expected4, [fillingWindow4 windowRect].position.x, 0);
    
    [handler setDelegate:nil];
    NSAssert(reportedStatus, @"Failed moving test rect 1: %f; rect2: %f", [fillingWindow3 windowRect].position.x, [fillingWindow4 windowRect].position.x);
    UKTrue(reportedStatus);
}

- (void)testFnIndexOfWindow
{
    NSInteger index = FnIndexOfWindow([uiHandler iconizedWindows], fillingWindow3);
    
    NSLog(@"Position %ld", index);
    
    UKIntsEqual(3, index);
    [handler setDelegate:nil];
    
    NSAssert(reportedStatus, @"Not Found");
    UKTrue(reportedStatus);
}


- (void) dealloc
{
    connection = nil;
    uiHandler = nil;
    handler = nil;
    findingWindow = nil;
    fillingWindow0 = nil;
    fillingWindow1 = nil;
    fillingWindow2 = nil;
    fillingWindow3 = nil;
    fillingWindow4 = nil;
}

@end