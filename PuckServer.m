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
@synthesize notificationLock;
@synthesize notifications;
@synthesize notificationPort;
@synthesize notificationThread;
@synthesize connection;

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

    /*defaultCenter = [NSDistributedNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(handleNotification:)
                          name:WINDOWSMAPUPDATED
                        object:nil];

    [[NSRunLoop currentRunLoop] run];*/
    
    return self;
}

- (void)addObserver
{
    [[NSRunLoop currentRunLoop] run];
}

- (void)handleNotification:(NSNotification *)aNotification
{
    if ([NSThread currentThread] != notificationThread)
    {
        NSLog(@"Epic fail");
        [notificationLock lock];
        [notifications addObject:aNotification];
        [notificationLock unlock];
        [notificationPort sendBeforeDate:[NSDate date] components:nil from:nil reserved:0];
    }
    else {
        NSLog(@"Received: %@", [aNotification name]);

        id <Server> server = (id <Server>) [NSConnection rootProxyForConnectionWithRegisteredName:@"UrosWMServer" host:@""];

        //NSLog(@"Uffa %@", [server handleRequestFor:WindowsMapRequest]);

        /*[connection setWindowsMap:nil];
        [connection setWindowsMap:[server handleRequestFor:WindowsMapRequest]];*/

        /*** update windows map ***/

         @synchronized (self)
         {
             NSLog(@"Uffa %@", [server handleRequestFor:WindowsMapRequest]);
             [connection setWindowsMap:nil];
             [connection setWindowsMap:[server handleRequestFor:WindowsMapRequest]];

             NSNotification *notification = [NSNotification notificationWithName:INTERNAL_WINDOWS_MAP_UPDATED object:nil];
             NSLog(@"Piripillo");
             [defaultCenter postNotification:notification];

             notification = nil;
         }

        server = nil;
    }
}

- (void)setupThreadingSupport
{
    if (notifications != nil)
        return;

    notifications = [[NSMutableArray alloc] init];
    notificationLock = [[NSLock alloc] init];
    notificationThread = [NSThread currentThread];

    notificationPort = [[NSMessagePort alloc] init];
    [notificationPort setDelegate:self];

    [[NSRunLoop currentRunLoop] addPort:[self notificationPort]
                                forMode:NSRunLoopCommonModes];
}

- (void)handlePortMessage:(NSPortMessage *)portMessage
{
    NSLog(@"Port message handler");

    [notificationLock lock];

    while ([notifications count])
    {
        NSNotification *notification = [self.notifications objectAtIndex:0];
        [notifications removeObjectAtIndex:0];
        [notificationLock unlock];
        [self handleNotification:notification];
        [notificationLock lock];

        notification = nil;
    }

    [notificationLock unlock];
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

    defaultCenter = [NSDistributedNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(handleNotification:)
                          name:WINDOWSMAPUPDATED
                        object:nil];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ server name: %@;", [PuckServer className], serverName];
}

- (void)detachServerInAnotherThreadWithConnection:(XCBConnection*)aConnection
{
    /*[conn runInNewThread];
    [self setupThreadingSupport];
    [self becomeServer];
    return [conn rootProxy];*/
    [self setupThreadingSupport];
    [self becomeServer];
    connection = aConnection;
    [[NSRunLoop currentRunLoop] run];
}

- (void) dealloc
{
    serverName = nil;
    [defaultCenter removeObserver:self];
    defaultCenter = nil;
    conn = nil;
    notifications = nil;
    notificationLock = nil;
    notificationThread = nil;
    notificationPort = nil;
    connection = nil;
}


@end