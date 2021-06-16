//
// PuckEventHandlerFactory
// Puck
//
// Created by slex on 05/06/21.

#import "PuckEventHandlerFactory.h"
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
    {
        NSLog(@"ClientList");
        [uiHandler updateClientList];

        int size = [[uiHandler puckUtils] clientListSize];
        NSLog(@"New client List updated");

        NSArray *windows = [[connection windowsMap] allValues];

        for (int i = 0; i < size; ++i)
            [[uiHandler puckUtils] addListenerForWindow:[windows objectAtIndex:i] withMask:DOCKMASK];

        windows = nil;
    }

    if ([atomService atomFromCachedAtomsWithKey:[ewmhService EWMHClientListStacking]] == anEvent->atom)
        NSLog(@"ClientListStacking");

    if ([atomService atomFromCachedAtomsWithKey:[ewmhService EWMHWMStateHidden]] == anEvent->atom)
        NSLog(@"Hidden");

    if ([atomService atomFromCachedAtomsWithKey:[icccmService WMChangeState]] == anEvent->atom)
        NSLog(@"Change state");

    if ([atomService atomFromCachedAtomsWithKey:[icccmService WMState]] == anEvent->atom)
    {
        NSLog(@"WM STATE for window %u", anEvent->window);

        /*** TODO: Improve the code to handle the normal state or the iconic state ***/

        XCBWindow *window = [connection windowForXCBId:anEvent->window];
        XCBWindow *frame = [[window queryTree] parentWindow];

        if ([uiHandler inIconizedWindowsWithId:[frame window]])
        {
            [uiHandler removeFromIconizedWindows:frame];
            return;
        }

        XCBPoint position = XCBMakePoint(0,0);

        XCBWindow *iconized = [uiHandler iconizedWindowsContainer];

        [connection reparentWindow:frame toWindow:iconized position:position];
        [uiHandler addToIconizedWindows:frame];

        window = nil;
        iconized = nil;
        frame = nil;
    }



    atomService = nil;
    ewmhService = nil;
    icccmService = nil;
}

- (void)dealloc
{
    connection = nil;
    uiHandler = nil;
}

@end