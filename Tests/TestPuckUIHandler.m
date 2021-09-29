//
// Boiler
// objc_boilers
//
// Created by slex on 21/08/21.

#import "TestPuckUIHandler.h"

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
    
    findingWindow = [[XCBWindow alloc] initWithXCBWindow:1002 andConnection:connection];
    
    fillingWindow0 = [[XCBWindow alloc] initWithXCBWindow:1000 andConnection:connection];
    fillingWindow1 = [[XCBWindow alloc] initWithXCBWindow:1001 andConnection:connection];
    fillingWindow2 = [[XCBWindow alloc] initWithXCBWindow:1002 andConnection:connection];
    fillingWindow3 = [[XCBWindow alloc] initWithXCBWindow:1003 andConnection:connection];
    fillingWindow4 = [[XCBWindow alloc] initWithXCBWindow:1004 andConnection:connection];
    
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