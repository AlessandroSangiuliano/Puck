//
// PuckServer
// Puck
//
// Created by slex on 24/11/21.

#import "PuckServer.h"
#import <XCBKit/XCBConnection.h>
#import "defines/NotificationDefines.h"
#import <sys/syscall.h>
#include <sys/types.h>
#include <unistd.h>

@implementation PuckServer

@synthesize serverName;
@synthesize defaultCenter;
@synthesize conn;

- (instancetype)initWithName:(NSString *)aServerName
{
    self = [super init];
    
    if (self == nil)
    {
        NSLog(@"Unable to init...");
        return nil;
    }
    
    serverName = aServerName;
    conn = [NSConnection new];
    
    defaultCenter = [NSDistributedNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(handleNotification:)
                          name:WINDOWSMAPUPDATED
                        object:nil];
    
    return self;
}

- (void)addObserver
{
    [[NSRunLoop currentRunLoop] run];
}

- (void)handleNotification:(NSNotification *)aNotification
{
    NSLog(@"Received: %@", [aNotification name]);
    
    id <Server> server = (id <Server>) [NSConnection rootProxyForConnectionWithRegisteredName:@"UrosWMServer" host:@""];
    XCBConnection *connection = [XCBConnection sharedConnectionAsWindowManager:NO];
    
    NSLog(@"Uffa %@", [server handleRequestFor:WindowsMapRequest]);
    
    /*** update windows map ***/
    
   /* @synchronized (self)
    {
        [connection setWindowsMap:nil];
       // [connection setWindowsMap:[server handleRequestFor:WindowsMapRequest]];
        
        NSNotification *notification = [NSNotification notificationWithName:INTERNAL_WINDOWS_MAP_UPDATED object:nil];
        NSLog(@"Piripillo");
        //[defaultCenter postNotification:notification];
        
        notification = nil;
    }*/
    
    server = nil;
    connection = nil;
}

- (void)becomeServer
{
    if (![conn registerName:serverName])
    {
        NSLog(@"Could not register as server...");
        return;
    }
    
    NSLog(@"Registered Puck as server");
    
    [conn setRootObject:self];
    
} 

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ server name: %@;", [PuckServer className], serverName];
}

- (id)detachServerInAnotherThread
{
    [conn runInNewThread];
    [self becomeServer];
    return [conn rootProxy];
}

- (void) dealloc
{
    serverName = nil;
    //defaultCenter = nil;
    conn = nil;
}


@end