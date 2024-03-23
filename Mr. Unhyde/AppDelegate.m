//
//  AppDelegate.m
//  Mr. Unhyde
//
//  Created by Eroica on 20.10.23.
//

#import "AppDelegate.h"
#import "MouseObserver.h"
#import "PreferencesController.h"
#import "Errors.h"

@interface AppDelegate ()

@property (strong) IBOutlet PreferencesController *preferencesController;
@property (weak) IBOutlet NSMenu *appMenu;
@property (weak) IBOutlet NSMenuItem *preferencesMenuItem;

@property (strong, nonatomic) NSStatusItem *statusItem;
@property MouseObserver *mouseObserver;

- (IBAction)togglePaused:(id)sender;

@end

@implementation AppDelegate {
    BOOL isDockVisibleAtStart;
}

+ (void)initialize {
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
        @"isMousePosition": @YES,
        @"isMouseSpeed": @YES,
        @"mousePosition": @"50 %",
        @"mouseSpeed": @1
    }];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    @try {
        NSScreen *mainScreen = [NSScreen mainScreen];
        isDockVisibleAtStart = !NSEqualRects([mainScreen visibleFrame], [mainScreen frame]);
        self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        self.statusItem.button.title = @"Mr. Unhyde";
        self.statusItem.menu = self.appMenu;

        Boolean dockIsAutoHideValid = false;
        Boolean isDockAutoHide = CFPreferencesGetAppBooleanValue(CFSTR("autohide"), CFSTR("com.apple.dock"), &dockIsAutoHideValid);

        if (isDockAutoHide) {
            /* Mr. Unhyde needs to control the Dock by itself, so exit here */
            NSString *message = NSLocalizedString(@"InitalizationError", @"Error shown when auto-hide is enabled");
            @throw [[InitializationError alloc] initWithMessage:message];
        }

        self.mouseObserver = [[MouseObserver alloc] init];

        if (isDockVisibleAtStart) {
            [self.mouseObserver toggleDock];
            self.mouseObserver.dockHidden = YES;
        }

        self.preferencesController.mouseObserver = self.mouseObserver;
    } @catch (InitializationError *e) {
        showErrorDialog(e.reason);
        [NSApp terminate:self];
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    if (self.mouseObserver != nil) {
        if (self.mouseObserver.isDockHidden && isDockVisibleAtStart) {
            [self.mouseObserver toggleDock];
        }
        
        [self.mouseObserver onDestroy];
    }
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    [NSApp activateIgnoringOtherApps:YES];
    [self.preferencesController showWindow:self];
    return NO;
}


- (IBAction)onOpenPreferencesClicked:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [self.preferencesController showWindow:self];
}


- (IBAction)togglePaused:(id)sender {
    NSMenuItem *pauseItem = (NSMenuItem *)sender;
    [pauseItem setState:([pauseItem state] == NSControlStateValueOn) ? NSControlStateValueOff : NSControlStateValueOn];
    self.mouseObserver.paused = pauseItem.state == NSControlStateValueOn;
}

@end
