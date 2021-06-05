//
//  main.m
//  uroswm
//
//  Created by Alessandro Sangiuliano on 22/06/20.
//  Copyright (c) 2020 Alessandro Sangiuliano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PuckUIHandler.h"


int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        // insert code here...
        NSLog(@"Starting Puck Dock...");

        PuckEventHandler *eventHandler = [[PuckEventHandler alloc] init];
        XCBConnection *connection = [[XCBConnection alloc] initAsWindowManager:NO];
        PuckUIHandler *uiHandler = [[PuckUIHandler alloc] initWithConnection:connection];
        [uiHandler drawDock:200 andHeigth:80];
        [eventHandler startEventHandlerLoop];

    return 0;
}
