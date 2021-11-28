//
// PuckServer
// Puck
//
// Created by slex on 24/11/21.
//

#import <Foundation/Foundation.h>
#import <XCBKit/protocols/server/Server.h>

@interface PuckServer : NSObject <Server>
{
}

@property (nonatomic, strong) NSString *serverName;
@property (nonatomic, strong) NSDistributedNotificationCenter *defaultCenter;
@property (nonatomic, strong) NSConnection *conn;

- (instancetype) initWithName:(NSString *)aServerName;
- (void) handleNotification:(NSNotification *)aNotification;
- (NSString *) description;
- (void) becomeServer;
- (void) addObserver;
- (id) detachServerInAnotherThread;

@end