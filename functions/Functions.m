//
// Functions
// Puck
//
// Created by slex on 01/11/21.

#import "Functions.h"

XCBPoint FnCalculateNewPosition(XCBWindow *movingWindow, int offset)
{
    XCBPoint newPosition = XCBMakePoint(([movingWindow windowRect].position.x - 50) - offset * 2 - 3, [movingWindow windowRect].position.y);
    return newPosition;
}

NSInteger FnIndexOfWindow(NSMutableArray *anArray, XCBWindow *searchingWindow)
{
    NSInteger index = -1;
    NSInteger count = [anArray count];
    
    for (int i = 0; i < count; ++i)
    {
        XCBWindow *window = [anArray objectAtIndex:i];
        
        if ([searchingWindow window] == [window window])
        {
            index = i;
            window = nil;
            break;
        }
    }
    
    return index;
}