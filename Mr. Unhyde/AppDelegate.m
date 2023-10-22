//
//  AppDelegate.m
//  Mr. Unhyde
//
//  Created by Eroica on 20.10.23.
//

#import "AppDelegate.h"
#import "MouseObserver.h"
#import "PreferencesController.h"

@interface AppDelegate ()

@property (strong) IBOutlet PreferencesController *preferencesController;
@property (weak) IBOutlet NSMenu *appMenu;
@property (weak) IBOutlet NSMenuItem *preferencesMenuItem;

@property (strong, nonatomic) NSStatusItem *statusItem;
@property MouseObserver *mouseObserver;

@end

@implementation AppDelegate

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
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.button.title = @"Mr. Unhyde";
    self.statusItem.menu = self.appMenu;
    
    Boolean dockIsAutoHideValid = false;
    Boolean isDockAutoHide = CFPreferencesGetAppBooleanValue(CFSTR("autohide"), CFSTR("com.apple.dock"), &dockIsAutoHideValid);
    
    self.mouseObserver = [[MouseObserver alloc] initWithDockStateHidden:!isDockAutoHide];
    self.preferencesController.mouseObserver = self.mouseObserver;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    if (self.mouseObserver != nil) {
        [self.mouseObserver toggleDock];
        [self.mouseObserver onDestroy];
    }
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


- (IBAction)onOpenPreferencesClicked:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [self.preferencesController showWindow:self];
}

@end
