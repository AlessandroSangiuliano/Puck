//
// PuckEventHandlerFactory
// Puck
//
// Created by slex on 05/06/21.

#import "PuckEventHandlerFactory.h"
#import <XCBKit/services/XCBAtomService.h>
#import <XCBKit/services/EWMHService.h>
#import <XCBKit/services/ICCCMService.h>

@implementation PuckEventHandlerFactory

@synthesize connection;
@synthesize uiHandler;

- (id)initWithConnection:(XCBConnection*)aConnection andUiHandler:(PuckUIHandler*)anUiHandler
{
    self = [super init];

    if (self == nil)
    {
        NSLog(@"Unable to init...");
        return nil;
    }

    uiHandler = anUiHandler;
    connection = aConnection;

    return self;
}

- (void)handlePropertyNotify:(xcb_property_notify_event_t*)anEvent
{
    EWMHService *ewmhService = [EWMHService sharedInstanceWithConnection:connection];
    ICCCMService *icccmService = [ICCCMService sharedInstanceWithConnection:connection];
    XCBAtomService *atomService = [XCBAtomService sharedInstanceWithConnection:connection];

    if ([atomService atomFromCachedAtomsWithKey:[ewmhService EWMHClientList]] == anEvent->atom)
        NSLog(@"ClientList");

    if ([atomService atomFromCachedAtomsWithKey:[ewmhService EWMHClientListStacking]] == anEvent->atom)
        NSLog(@"ClientListStacking");

    if ([atomService atomFromCachedAtomsWithKey:[ewmhService EWMHWMStateHidden]] == anEvent->atom)
        NSLog(@"Hidden");

    if ([atomService atomFromCachedAtomsWithKey:[icccmService WMChangeState]] == anEvent->atom)
        NSLog(@"Change state");

    if ([atomService atomFromCachedAtomsWithKey:[icccmService WMState]] == anEvent->atom)
    {
        NSNumber *key = [[NSNumber alloc] initWithInt:anEvent->window];
        XCBWindow *window = [[connection windowsMap] objectForKey:key];
        XCBWindow *frame = [[window queryTree] parentWindow];

        XCBPoint position = XCBMakePoint(0,0);

        XCBWindow *iconized = [uiHandler iconizedWindowsContainer];

        [connection reparentWindow:frame toWindow:iconized position:position];
        [connection mapWindow:frame];

        key = nil;
        window = nil;
        iconized = nil;
        frame = nil;
    }



    atomService = nil;
    ewmhService = nil;
}

- (void)dealloc
{
    connection = nil;
    uiHandler = nil;
}

@end