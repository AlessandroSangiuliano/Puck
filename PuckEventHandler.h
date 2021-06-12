//
// PuckEventHandler
// Puck
//
// Created by slex on 30/05/21.
//

#import <Foundation/Foundation.h>
#import "PuckUIHandler.h"

@interface PuckEventHandler : NSObject
{
}

@property (strong, nonatomic) PuckUIHandler *uiHandler;

-(id) initWithUIHandler:(PuckUIHandler*)anUiHandler;

- (void) startEventHandlerLoop;
- (void) addListenerForWindow:(XCBWindow*)aWindow;

@end