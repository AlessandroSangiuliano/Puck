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
    NSLog(@"Relle: %@", [server handleRequestFor:WindowsMapRequest]);
}

- (void) dealloc
{
    serverName = nil;
}


@end