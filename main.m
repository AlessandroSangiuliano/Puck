//
//  main.m
//  uroswm
//
//  Created by Alessandro Sangiuliano on 22/06/20.
//  Copyright (c) 2020 Alessandro Sangiuliano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PuckUIHandler.h"
#import "PuckEventHandler.h"


int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        // insert code here...
        NSLog(@"Starting Puck Dock...");

        XCBConnection *connection = [[XCBConnection alloc] initAsWindowManager:NO];
        PuckUIHandler *uiHandler = [[PuckUIHandler alloc] initWithConnection:connection];
        PuckEventHandler *eventHandler = [[PuckEventHandler alloc] initWithUIHandler:uiHandler];
        [uiHandler drawDock:200 andHeigth:60];

        int size = [[uiHandler puckUtils] clientListSize];

        NSArray *windows = [[connection windowsMap] allValues];

        for (int i = 0; i < size; ++i)
        {
            [eventHandler addListenerForWindow:[windows objectAtIndex:i]];
        }

        windows = nil;

        [eventHandler startEventHandlerLoop];
}

    return 0;
}
