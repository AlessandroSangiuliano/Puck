//
//  main.m
//  uroswm
//
//  Created by Alessandro Sangiuliano on 22/06/20.
//  Copyright (c) 2020 Alessandro Sangiuliano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PuckUIHandler.h"
#import "PuckRunLoop.h"
#import "PuckServer.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        // insert code here...
        NSLog(@"Starting Puck Dock...");

        XCBConnection *connection = [XCBConnection sharedConnectionAsWindowManager:NO];
        PuckUIHandler *uiHandler = [[PuckUIHandler alloc] initWithConnection:connection];
        PuckRunLoop *puckRunLoop = [[PuckRunLoop alloc] initWithUIHandler:uiHandler];
    
        [uiHandler drawDock:200 andHeigth:60];
        //[uiHandler setupServer];
    
        //[NSThread detachNewThreadSelector:@selector(startEventHandlerLoop) toTarget:puckRunLoop withObject:nil]; working in the main thread
        
        [uiHandler addObserver];
    
        //[NSThread detachNewThreadSelector:@selector(addObserver) toTarget:uiHandler withObject:nil];
    
        //PuckServer *puckServer = [[[PuckServer alloc] initWithName:@"PuckServer"] detachServerInAnotherThread];

        PuckServer *puckServer = [[PuckServer alloc] initWithName:@"PuckServer"];
        
        //[puckServer setConnection:connection];
        /*[puckServer setupThreadingSupport]; working in the main thread
        [puckServer becomeServer];*/
        //PuckServer *thr = (PuckServer *) [puckServer detachThread];

        [NSThread detachNewThreadSelector:@selector(detachServerInAnotherThreadWithConnection:) toTarget:puckServer withObject:connection];
        
        //[puckServer addObserver];
    
        //NSLog(@"Ciccio %@", [puckServer description]);
        
        //[[NSRunLoop currentRunLoop] run];
    
        //[NSThread detachNewThreadSelector:@selector(becomeServer) toTarget:puckServer withObject:nil];
        /*NSThread *serverThread = [[NSThread alloc] initWithTarget:puckServer selector:@selector(becomeServer) object:nil];
        [serverThread start];*/
        
        [puckRunLoop startEventHandlerLoop];
    }

    return 0;
}
