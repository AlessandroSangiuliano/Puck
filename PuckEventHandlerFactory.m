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
            
            [win updateAttributes];
            [win refreshCachedWMHints];
            [win generateWindowIcons];
            [win drawIcons];
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
        XCBFrame *frame = (XCBFrame*) [window parentWindow];
    
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
    
    /*** if window is minimized execute this handler otherwise just remove it from the connection ***/
    
    XCBWindow *window = [connection windowForXCBId:anEvent->window];
    frame = (XCBFrame*) [window parentWindow];
    
    if (!window)
        return;
    
    PuckUtils *puckUtils = [uiHandler puckUtils];
    
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
    BOOL present = NO;
    XCBWindow *window = [uiHandler windowFromIconizedById:anEvent->window]; //[connection windowForXCBId:anEvent->window];
    EncapsulatedWindow *encapsulatedWindow;
    
    PuckUtils *puckUtils = [uiHandler puckUtils];
    
    [uiHandler updateClientList];
    
    if (!window)
    {
        encapsulatedWindow = [puckUtils encapsulateWindow:anEvent->window];
    
        if (!encapsulatedWindow)
            return;
        
    }
    else
    {
        encapsulatedWindow = [[EncapsulatedWindow alloc] init];
        [encapsulatedWindow setWindow:window];
        XCBQueryTreeReply *queryTreeReply = [window queryTree];
        [encapsulatedWindow setChildren:[queryTreeReply queryTreeAsArray]];
        [encapsulatedWindow setChildrenLen:[queryTreeReply childrenLen]];
        queryTreeReply = nil;
    }
    
    if ([[encapsulatedWindow window] isMinimized])
    {
        puckUtils = nil;
        encapsulatedWindow = nil;
        return;
    }
    
    xcb_window_t *children = [encapsulatedWindow children]; //FIXME: must be free´d ?
    
    int count = [encapsulatedWindow childrenLen];
    
    for (int i = 0; i < count; i++)
    {
        present = FnIsWindowInClientList(children[i], [uiHandler clientList], [[uiHandler puckUtils] clientListSize]);
    
        if (present)
        {
            window = [[XCBWindow alloc] initWithXCBWindow:children[i] andConnection:connection];
            [puckUtils registerWindow:window];
            [window setParentWindow:[encapsulatedWindow window]];
            [window updateAttributes];
            [window refreshCachedWMHints];
            [window generateWindowIcons];
            [puckUtils addListenerForWindow:window withMask:DOCKMASK];
            break;
        }
        
    }
    
    puckUtils = nil;
    window = nil;
    encapsulatedWindow = nil;
}


- (void)dealloc
{
    connection = nil;
    uiHandler = nil;
}

@end