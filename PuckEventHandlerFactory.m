//
// PuckEventHandlerFactory
// Puck
//
// Created by slex on 05/06/21.

#import "PuckEventHandlerFactory.h"
#import <XCBKit/services/ICCCMService.h>
#import <XCBKit/XCBFrame.h>

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
        
        NSArray *windows = [[connection windowsMap] allValues];
        
        //TODO: print the windows map and the client list

        for (int i = 0; i < [windows count]; ++i)
        {
            XCBWindow *win = [windows objectAtIndex:i];
            NSLog(@"Add listener for dockWindow %u", [win window]);
            [[uiHandler puckUtils] addListenerForWindow:[windows objectAtIndex:i] withMask:DOCKMASK];
            win = nil;
        }

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
        NSLog(@"WM STATE for dockWindow %u", anEvent->window);
        WindowState wmState = -1;

        XCBWindow *window = [connection windowForXCBId:anEvent->window];
        XCBFrame *frame = (XCBFrame *)[[window queryTree] parentWindow];
    
        if (frame)
            wmState = [icccmService wmStateFromWindow:frame];

        switch (wmState)
        {
            case ICCCM_WM_STATE_NORMAL:
            {
                BOOL needResize = NO;
                BOOL forl = NO;
                
                NSLog(@"Normal state for dockWindow: %u and frame: %u", [window window], [frame window]);
                
                if ([[uiHandler iconizedWindows] count] > 1)
                    needResize = YES;
                
                forl = [uiHandler isIconizedInFirstOrLastPosition:frame];
                
                NSInteger followingWinsCount = [uiHandler countFollowingWindowsForWindow:frame];
                
                XCBWindow *dockWindow = [uiHandler dockWindow];
                XCBWindow *iconizedContainerWindow = [uiHandler iconizedWindowsContainer];
                
                /*** if forl, is followed and need resize, then it is in first position! ***/
                
                if (needResize && [uiHandler isFollowedByAnotherWindow:frame] && forl)
                {
                    [uiHandler moveFollowingWindows:followingWinsCount forWindow:frame];
                    [uiHandler removeFromIconizedWindowsById:[frame window]];
                    
                    /*** resize the dock ***/
                    
                    XCBRect iconizedContainerRect = [iconizedContainerWindow windowRect];
                    XCBPoint newMainWindowPos = XCBMakePoint(([dockWindow windowRect].position.x + 50) - OFFSET * 2 - 3, [dockWindow windowRect].position.y);
                    XCBSize newIconizedContainerSize = XCBMakeSize(iconizedContainerRect.size.width - 50 - OFFSET *  2 - 3, iconizedContainerRect.size.height);
                    [uiHandler resizeToPosition:newMainWindowPos andSize:newIconizedContainerSize resize:Reduce];
                    
                    [connection flush];
                }
                
                dockWindow = nil;
                iconizedContainerWindow = nil;
                break;
            }
            case ICCCM_WM_STATE_ICONIC:
            {
                NSLog(@"Normal state for dockWindow: %u and frame: %u", [window window], [frame window]);
                [uiHandler addToIconizedWindowsContainer:frame];
                break;
            }
            default:
                break;
        }

        window = nil;
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