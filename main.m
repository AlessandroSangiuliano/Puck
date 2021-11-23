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

        int size = [[uiHandler puckUtils] clientListSize];
        
        NSArray *windows = [[connection windowsMap] allValues];

        for (int i = 0; i < size; ++i)
            [[uiHandler puckUtils] addListenerForWindow:[windows objectAtIndex:i] withMask:DOCKMASK];
        

        windows = nil;

        [puckRunLoop startEventHandlerLoop];
}

    return 0;
}
