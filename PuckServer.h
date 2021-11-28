//
// PuckServer
// Puck
//
// Created by slex on 24/11/21.
//

#import <Foundation/Foundation.h>
#import <XCBKit/protocols/server/Server.h>

@class XCBConnection;

@interface PuckServer : NSObject <Server>
{
}

@property (nonatomic, strong) NSString *serverName;
@property (nonatomic, strong) NSDistributedNotificationCenter *defaultCenter;
@property (nonatomic, strong) NSConnection *conn;
@property (nonatomic, strong) XCBConnection *connection;

/*** Threading properties ***/

@property (nonatomic, strong) NSMutableArray *notifications;
@property (nonatomic, strong) NSThread *notificationThread;
@property (nonatomic, strong) NSLock *notificationLock;
@property (nonatomic, strong) NSMessagePort *notificationPort;

- (instancetype) initWithName:(NSString *)aServerName;
- (void) handleNotification:(NSNotification *)aNotification;
- (NSString *) description;
- (void) becomeServer;
- (void) addObserver;
- (void) detachServerInAnotherThreadWithConnection:(XCBConnection*)aConnection;
- (void) setupThreadingSupport;
- (void)handlePortMessage:(NSPortMessage*) portMessage;

@end