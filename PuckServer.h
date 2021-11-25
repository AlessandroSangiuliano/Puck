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

- (instancetype) initWithName:(NSString *)aServerName;

- (void) handleNotification:(NSNotification *)aNotification;

@end