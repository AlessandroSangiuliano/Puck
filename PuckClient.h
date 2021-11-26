//
// PuckClient
// Puck
//
// Created by slex on 24/11/21.
//

#import <Foundation/Foundation.h>
#import <XCBKit/protocols/client/Client.h>

@class XCBConnection;

@interface PuckClient : NSObject <Client>
{
}

@property (strong, nonatomic)  XCBConnection *connection;

- (instancetype) initWithConnection:(XCBConnection *)aConnection;

@end