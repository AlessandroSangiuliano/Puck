//
// PuckClient
// Puck
//
// Created by slex on 24/11/21.

#import "PuckClient.h"
#import <XCBKit/XCBConnection.h>

@implementation PuckClient

@synthesize connection;

- (instancetype)initWithConnection:(XCBConnection *)aConnection
{
    self = [super init];
    
    if (self == nil)
    {
        NSLog(@"Unable to init..");
        return nil;
    }
    
    connection = aConnection;
    
    return self;
}

- (void) dealloc
{
    connection = nil;
}

@end