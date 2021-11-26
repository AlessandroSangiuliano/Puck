//
// PuckServer
// Puck
//
// Created by slex on 24/11/21.

#import "PuckServer.h"
#import <XCBKit/XCBConnection.h>

@implementation PuckServer

@synthesize serverName;

- (instancetype)initWithName:(NSString *)aServerName
{
    self = [super init];
    
    if (self == nil)
    {
        NSLog(@"Unable to init...");
        return nil;
    }
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(handleNotification:)
                                                            name:WINDOWSMAPUPDATED
                                                          object:nil];
    
    serverName = aServerName;
    [[NSRunLoop mainRunLoop] run];
    return self;
}

- (void)handleNotification:(NSNotification *)aNotification
{
    NSLog(@"Received: %@", [aNotification name]);
    
    id <Server> server = (id <Server>) [NSConnection rootProxyForConnectionWithRegisteredName:@"UrosWMServer" host:@""];
    XCBConnection *connection = [XCBConnection sharedConnectionAsWindowManager:NO];
    [connection setWindowsMap:[server handleRequestFor:WindowsMapRequest]];
    
    server = nil;
    connection = nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ server name: %@", [PuckServer className], serverName];
}

- (void) dealloc
{
    serverName = nil;
}


@end