//
// PuckUIHandler
// Puck
//
// Created by slex on 28/05/21.

#import "PuckUIHandler.h"
#import <XCBKit/XCBFrame.h>
#import <XCBKit/protocols/server/Server.h>
#import "functions/Functions.h"
#import "defines/NotificationDefines.h"


@implementation PuckUIHandler

@synthesize dockWindow;
@synthesize separatorWindow;
@synthesize clientList;
@synthesize puckUtils;
@synthesize connection;
@synthesize iconizedWindows;
@synthesize iconizedWindowsContainer;
@synthesize server;
@synthesize semaphore;

- (instancetype)init
{
    return [self initWithConnection:nil];
}

- (id)initWithConnection:(XCBConnection*)aConnection
{
    self = [super init];

    if (self == nil)
    {
        NSLog(@"Unable to init...");
        return nil;
    }

    connection = aConnection;
    puckUtils = [[PuckUtils alloc] initWhitConnection:connection];

    clientList = [puckUtils queryForNetClientList]; /** we have clientList in the connection too. it could be reused **/

    iconizedWindows = [[NSMutableArray alloc] init];
    
    semaphore = NO;

    /*int size = [puckUtils clientListSize];

    for (int i = 0; i < size; ++i)
        [puckUtils encapsulateWindow:clientList[i]];*/

    return self;
}

- (void)drawDock:(CGFloat)width andHeigth:(CGFloat)height
{
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    XCBWindow *rootWindow = [screen rootWindow];

    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];

    uint32_t values[] = {[screen screen]->white_pixel, FRAMEMASK};

    XCBCreateWindowTypeRequest *request = [[XCBCreateWindowTypeRequest alloc] initForWindowType:XCBWindowRequest];

    [request setParentWindow:rootWindow];
    [request setDepth:[screen screen]->root_depth];
    [request setXPosition:[screen width] / 2 - width / 2];
    [request setYPosition:[screen height] - height];
    [request setWidth:width];
    [request setHeight:height];
    [request setBorderWidth:0];
    [request setXcbClass:XCB_WINDOW_CLASS_INPUT_OUTPUT];
    [request setValueMask:XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK];
    [request setValueList:values];

    XCBWindowTypeResponse *response = [connection createWindowForRequest:request registerWindow:NO];
    dockWindow = [response window];
    values[0] = 1;
    values[1] = 0;

    [dockWindow changeAttributes:values withMask:XCB_CW_OVERRIDE_REDIRECT checked:NO];

    uint32_t val[] = {DOCKMASK};
    [rootWindow changeAttributes:val withMask:XCB_CW_EVENT_MASK checked:NO];
    
    [dockWindow stackAbove];
    EWMHService *ewmhService = [EWMHService sharedInstanceWithConnection:connection];
    [ewmhService updateNetWmState:dockWindow];

    /*** Request for the iconized windows container ***/
    
    response = nil;

    [request setParentWindow:dockWindow];
    [request setXPosition:width - 58];
    [request setYPosition:height - 58];
    [request setWidth:56];
    [request setHeight:height];

    values[0] = [screen screen]->white_pixel;
    values[1] = FRAMEMASK;

    response = [connection createWindowForRequest:request registerWindow:NO];

    iconizedWindowsContainer = [response window];
    
    /*** Request for separator window ***/
    
    response = nil;
    
    [request setParentWindow:dockWindow];
    [request setXPosition:width - 62];
    [request setYPosition:height - 58];
    [request setWidth:2];
    [request setHeight:56];
    
    values[0] = [screen screen]->black_pixel;
    values[1] = FRAMEMASK;
    
    response = [connection createWindowForRequest:request registerWindow:NO];
    separatorWindow = [response window];
    
    [connection mapWindow:dockWindow];
    [connection mapWindow:iconizedWindowsContainer];
    [connection mapWindow:separatorWindow];
    [connection flush];
    
    screen = nil;
    request = nil;
    response = nil;
    visual = nil;
    rootWindow = nil;
    ewmhService = nil;
}

- (void)resizeToPosition:(XCBPoint)aPosition andSize:(XCBSize)aSize resize:(Resize)aResize
{
    /*** for the main dockbar dockWindow we calculate the new size, while the position is given by the aPosition argument ***/
    
    XCBSize newMainSize;
    
    if (aResize == Enlarge)
        newMainSize = XCBMakeSize([dockWindow windowRect].size.width + 50 + OFFSET * 2 + 3, aSize.height);
    else
        newMainSize = XCBMakeSize([dockWindow windowRect].size.width - 50 - OFFSET * 2 - 3, aSize.height);
    
    [dockWindow maximizeToSize:newMainSize andPosition:aPosition];
    [dockWindow setIsMaximized:NO];
    [dockWindow setFullScreen:NO];
    [dockWindow setMaximizedVertically:NO];
    [dockWindow setMaximizedHorizontally:NO];
    
    /*** for the iconified container we keep the same position and give to it the size from the aSize paramenter ***/
    
    [iconizedWindowsContainer maximizeToSize:aSize andPosition:[iconizedWindowsContainer windowRect].position];
    [iconizedWindowsContainer setIsMaximized:NO];
    [iconizedWindowsContainer setFullScreen:NO];
    [iconizedWindowsContainer setMaximizedVertically:NO];
    [iconizedWindowsContainer setMaximizedHorizontally:NO];
}

- (void)addToIconizedWindowsContainer:(XCBWindow*)aWindow
{
    NSLog(@"Adding window %u", [aWindow window]);
    
    BOOL needResize = NO;
    
    if ([iconizedWindows count] != 0)
        needResize = YES;
    
    [iconizedWindows addObject:aWindow];
    
    if (needResize)
    {
        XCBRect rect = [iconizedWindowsContainer windowRect];
        XCBPoint newMainWindowPos = XCBMakePoint(([dockWindow windowRect].position.x - 50) + OFFSET * 2 + 3, [dockWindow windowRect].position.y); //TODO: CHECK If bette + OFFSET etc etc or - OFFSET etc etc
        XCBSize newContainerWindowSize = XCBMakeSize(rect.size.width + 50 + OFFSET * 2 + 3, rect.size.height);
        [self resizeToPosition:newMainWindowPos andSize:newContainerWindowSize resize:Enlarge];
        XCBPoint repPos = XCBMakePoint([iconizedWindowsContainer windowRect].size.width - 50 - OFFSET, 0);
        [connection reparentWindow:aWindow toWindow:iconizedWindowsContainer position:repPos];
        [connection flush];
    
    }
    else
        [connection reparentWindow:aWindow toWindow:iconizedWindowsContainer position:XCBMakePoint(0,0)];
    
}

- (void)removeFromIconizedWindowsById:(xcb_window_t)winId
{
    int size = [iconizedWindows count];
    
    NSLog(@"Size before removing: %d", size);
    
    for (int i = 0; i < size; ++i)
    {
        XCBWindow *win = [iconizedWindows objectAtIndex:i];
        
        if ([win window] == winId)
        {
            [iconizedWindows removeObjectAtIndex:i];
            win = nil;
            break;
        }
        
        win = nil;
    }
}

- (XCBWindow *)windowFromIconizedById:(xcb_window_t)winId
{
    XCBWindow *win;
    int size = [iconizedWindows count];
    
    for (int i = 0; i < size; ++i)
    {
        win = [iconizedWindows objectAtIndex:i];
        
        if ([win window] == winId)
            return win;
        
        win = nil;
    }
    
    return win;
}

- (BOOL)isIconizedInFirstOrLastPosition:(XCBWindow *)aWindow
{
    XCBWindow *first;
    XCBWindow *last;
    BOOL firstOrLast = NO;
    
    first = [iconizedWindows firstObject];
    last = [iconizedWindows lastObject];
    
    if ([first window] == [aWindow window] || [last window] == [aWindow window])
        firstOrLast = YES;
    
    return firstOrLast;
}

- (BOOL)isFollowedByAnotherWindow:(XCBWindow *)originWindow
{
    BOOL followed = NO;
    
    int arraySize = [iconizedWindows count];
    
    if (arraySize == 1)
        return followed;
    
    if (arraySize > 1)
    {
        for (int i = 0; i < arraySize; ++i)
        {
            XCBWindow *auxWin = [iconizedWindows objectAtIndex:i];
            XCBWindow *lastWindow = [iconizedWindows lastObject];
            
            if ([originWindow window] == [auxWin window] && [originWindow window] != [lastWindow window])
            {
                XCBWindow *following = [iconizedWindows objectAtIndex:i+1];
                
                if (following != nil)
                {
                    followed = YES;
                    following = nil;
                    auxWin = nil;
                    lastWindow = nil;
                    break;
                }
            }
            else if ([originWindow window] == [lastWindow window])
            {
                auxWin = nil;
                lastWindow = nil;
                return followed;
            }
            
            auxWin = nil;
            lastWindow = nil;
        }
    }
    
    return followed;
}

- (NSInteger) countFollowingWindowsForWindow:(XCBWindow *)aWindow
{
    NSInteger following = 0;
    
    int arraySize = [iconizedWindows count];
    
    XCBWindow *lastWindow = [iconizedWindows lastObject];
    
    if (arraySize == 1 || [aWindow window] == [lastWindow window])
    {
        lastWindow = nil;
        return following;
    }
    
    if (arraySize > 1)
    {
        for (int i = 0; i < arraySize; ++i)
        {
            XCBWindow *auxWin = [iconizedWindows objectAtIndex:i];
            
            if ([aWindow window] == [auxWin window])
            {
                following = arraySize - (i + 1);
                auxWin = nil;
                break;
            }
        }
    }
    
    lastWindow = nil;
    return following;
}

- (void) moveFollowingWindows:(NSInteger) followingQuantity forWindow:(XCBWindow *)originWindow
{
    NSInteger winPosition = FnIndexOfWindow(iconizedWindows, originWindow);
    
    for (int i = 0; i < followingQuantity; ++i)
    {
        winPosition++;
        XCBWindow *moving = [iconizedWindows objectAtIndex:winPosition];
        /*** XCBMakePoint(([dockWindow windowRect].position.x - 50) + OFFSET * 2 + 3, [dockWindow windowRect].position.y); ***/
        XCBPoint newPosition = FnCalculateNewPosition(moving, OFFSET);
        [self moveWindow:moving toPosition:newPosition];
        moving = nil;
    }
    
}

- (void)moveWindow:(XCBWindow *)aWindow toPosition:(XCBPoint)aPosition
{
    int32_t values[] = {aPosition.x, aPosition.y};

    xcb_configure_window([connection connection], [aWindow window], XCB_CONFIG_WINDOW_X | XCB_CONFIG_WINDOW_Y, values);

    XCBRect newRect = XCBMakeRect(aPosition, XCBMakeSize([aWindow windowRect].size.width, [aWindow windowRect].size.height));
    [aWindow setWindowRect:newRect];

    [aWindow setOriginalRect:XCBMakeRect(XCBMakePoint(aPosition.x, aPosition.y),
                                       XCBMakeSize([aWindow originalRect].size.width,
                                                   [aWindow originalRect].size.height))];
}

- (void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:INTERNAL_WINDOWS_MAP_UPDATED object:nil];
    /*NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop configureAsServer];
    [runLoop run];*/
    //[[NSRunLoop currentRunLoop] run];
}

- (void)handleNotification:(NSNotification *)aNotification
{
    semaphore = YES;
    NSLog(@"Vaggeggia" );
    /*NSDictionary *windowsMap = [aNotification userInfo];
    NSLog(@"Vaggeggia %@", windowsMap);
    
    @synchronized (self)
    {
        [self updateClientList];
        [self addListeners];
    }*/
    
    //[[NSRunLoop currentRunLoop] run];
    
   // windowsMap = nil;
}

- (void)addListeners
{
    int size = [puckUtils clientListSize];
    
    for (int i = 0; i <size ; ++i)
    {
        XCBWindow *window = [connection windowForXCBId:clientList[i]];
        NSLog(@"Adding %u", [window window]);
        [puckUtils addListenerForWindow:window withMask:DOCKMASK];
        window = nil;
    }
}

- (void)setupServer
{
    if (server == nil)
        server = (id <Server>) [NSConnection rootProxyForConnectionWithRegisteredName:@"UrosWMServer" host:@""];
    
    [connection setWindowsMap:nil];
    [connection setWindowsMap:[server handleRequestFor:WindowsMapRequest]];
    [self updateClientList];
    [self addListeners];
    NSLog(@"Pene %@", [connection windowsMap]);
}

- (void)updateClientList
{
    /*** TODO: CHECK IF THIS LEAKING ***/
    
    if (clientList)
        free(clientList);

    clientList = [puckUtils queryForNetClientList];
}

- (void)dealloc
{
    connection               = nil;
    dockWindow               = nil;
    iconizedWindowsContainer = nil;
    iconizedWindows = nil;
    puckUtils = nil;
    separatorWindow = nil;
    

    if (clientList)
        free(clientList); // is pure C, but inside there are unsigned int values
}

@end