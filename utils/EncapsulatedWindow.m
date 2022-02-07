//
// EncapsulatedWindow
// Puck
//
// Created by slex on 05/02/22.

#import "EncapsulatedWindow.h"

@implementation EncapsulatedWindow

@synthesize window;
@synthesize children;
@synthesize childrenLen;

- (instancetype)init
{
    self = [super init];
    
    if (self == nil)
    {
        NSLog(@"Unable to init...");
        return nil;
    }
    
    return self;
}

- (void)dealloc
{
    window = nil;
}

@end