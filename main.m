//
//  main.m
//  uroswm
//
//  Created by Alessandro Sangiuliano on 22/06/20.
//  Copyright (c) 2020 Alessandro Sangiuliano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PuckUIHandler.h"
#import <unistd.h>


int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        // insert code here...
        NSLog(@"Starting Puck Dock...");

        PuckUIHandler *handler = [[PuckUIHandler alloc] init];
        [handler drawDock:200 andHeigth:80];

        pause();
    }

    return 0;
}
