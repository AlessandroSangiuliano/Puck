//
// PuckEventHandlerFactory
// Puck
//
// Created by slex on 05/06/21.

#import "PuckEventHandlerFactory.h"
#import <XCBKit/services/ICCCMService.h>
#import <XCBKit/XCBFrame.h>
#import "functions/Functions.h"

@implementation PuckEventHandlerFactory

@synthesize connection;
@synthesize uiHandler;
@synthesize statusDestroy;

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
        
        //if (!statusDestroy)
            [uiHandler updateClientList];
        
        NSArray *windows = [[connection windowsMap] allValues];

        for (int i = 0; i < [windows count]; ++i)
        {
            XCBWindow *win = [windows objectAtIndex:i];
    
            if(![win onScreen])
            {
                win = nil;
                windows = nil;
                ewmhService = nil;
                atomService = nil;
                icccmService = nil;
                statusDestroy = NO;
                return;
            }
            
            NSLog(@"Add listener for window %u", [win window]);
            [win updateAttributes];
            [win refreshCachedWMHints];
            [win generateWindowIcons];
            [win drawIcons];
            //[[uiHandler puckUtils] addListenerForWindow:[windows objectAtIndex:i] withMask:DOCKMASK];
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
        NSLog(@"WM STATE for window %u", anEvent->window);
        WindowState wmState = -1;

        XCBWindow *window = [connection windowForXCBId:anEvent->window];
        XCBFrame *frame = (XCBFrame *)[[window queryTree] parentWindow]; //FIXME: when in the connection the parent window is just set!
    
        NSLog(@"Prop changed: %u frame window: %u", [window window], [frame window]);
    
        if (frame)
            wmState = [icccmService wmStateFromWindow:frame];

        switch (wmState)
        {
            case ICCCM_WM_STATE_NORMAL:
            {
                BOOL needResize = NO;
                BOOL forl = NO;
                
                NSLog(@"Normal state for window: %u and frame: %u", [window window], [frame window]);
                
                if ([[uiHandler iconizedWindows] count] > 1)
                    needResize = YES;
                
                forl = [uiHandler isIconizedInFirstOrLastPosition:frame];
                
                [uiHandler resize:forl needResize:needResize withFrame:frame];
                
                break;
            }
            case ICCCM_WM_STATE_ICONIC:
            {
                NSLog(@"Iconic state for window: %u and frame: %u", [window window], [frame window]);
                [uiHandler addToIconizedWindowsContainer:frame];
                break;
            }
            case ICCCM_WM_STATE_WITHDRAWN:
            {
                NSLog(@"WITHDRAWN state for window: %u and frame: %u", [window window], [frame window]);
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
    statusDestroy = NO;
}

- (void)handleDestroyNotify:(xcb_destroy_notify_event_t *)anEvent
{
    statusDestroy = YES;
    XCBFrame *frame;
    
    XCBWindow *window = [connection windowForXCBId:anEvent->window];
    
    PuckUtils *puckUtils = [uiHandler puckUtils];
    
    if (!window)
        return;
    
    if ([window isKindOfClass:[XCBFrame class]])
    {
        frame = (XCBFrame*) window;
    }
    else
        frame = (XCBFrame*) [window parentWindow];
    
    BOOL needResize = NO;
    BOOL forl = NO;
    
    if ([[uiHandler iconizedWindows] count] > 1)
        needResize = YES;
    
    forl = [uiHandler isIconizedInFirstOrLastPosition:frame];
    
    [uiHandler resize:forl needResize:needResize withFrame:frame];
    
    [puckUtils unregisterWindow:window];
}

- (void) handleMapNotify:(xcb_map_notify_event_t *)anEvent
{
    NSLog(@"Really mapped %u", anEvent->window);
    
    PuckUtils *puckUtils = [uiHandler puckUtils];
    
    /*BOOL present = FnIsWindowInClientList(anEvent->window, [uiHandler clientList], [[uiHandler puckUtils] clientListSize]);
    
    if (!present)
    {
        NSLog(@"Window not in client list");
        return;
    }*/
    
    [puckUtils encapsulateWindow:anEvent->window];
    
    NSLog(@"Windows map %@", [[connection windowsMap] description]);
    
    XCBWindow *window = [connection windowForXCBId:anEvent->window];
    
    [window updateAttributes];
    [window refreshCachedWMHints];
    [window generateWindowIcons];
    [window drawIcons];
    
    NSLog(@"Window %u found", [window window]);
    [window description];
    //[[window parentWindow] description];
    
    [puckUtils addListenerForWindow:window withMask:DOCKMASK];
    
    puckUtils = nil;
    window = nil;
    
    xcb_window_t *cl = [uiHandler clientList];
    
    for (int i = 0; i <[[uiHandler puckUtils] clientListSize]; ++i)
    {
        NSLog(@"Windows in client list: %u", cl[i]);
    }
}

- (void)handleCreateNotify:(xcb_create_notify_event_t *)anEvent
{
    /*PuckUtils *puckUtils = [uiHandler puckUtils];
    [uiHandler updateClientList];
    
    BOOL present = FnIsWindowInClientList(anEvent->window, [uiHandler clientList], [[uiHandler puckUtils] clientListSize]);
    
    if (!present)
    {
        NSLog(@"Window not in client list");
        return;
    }
    
    
    [puckUtils encapsulateWindow:anEvent->window];
    
    XCBWindow *window = [connection windowForXCBId:anEvent->window];
    
    [window updateAttributes];
    [window refreshCachedWMHints];
    [window generateWindowIcons];
    [window drawIcons];
    
    NSLog(@"Window %u found", [window window]);
    [window description];
    [[window parentWindow] description];
    
    [puckUtils addListenerForWindow:window withMask:DOCKMASK];
    
    puckUtils = nil;
    window = nil;*/
    
}


- (void)dealloc
{
    connection = nil;
    uiHandler = nil;
}

@end