//
//  AppDelegate.m
//  Observer
//
//  Created by Seba on 17.08.15.
//  Copyright (c) 2015 Lunation. All rights reserved.
//

#include <ApplicationServices/ApplicationServices.h>
#include <Carbon/Carbon.h>

#import "AppDelegate.h"
#import "MouseObserver.h"
#import "PreferencesController.h"


@interface AppDelegate ()

@property (weak) IBOutlet NSMenu *menu;
@property (weak) IBOutlet NSMenuItem *preferencesMenuItem;
@property (weak) IBOutlet NSWindow *preferencesWindow;


@property PreferencesController *preferencesController;

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (assign, nonatomic) BOOL darkModeOn;
@property MouseObserver *mouseObserver;


@end



@implementation AppDelegate

- (IBAction)openPreferences:(id)sender {
    [self.preferencesController showWindow:@"Preferences"];
}

- (void)refreshDarkMode {
    NSString * value = (__bridge NSString *)(CFPreferencesCopyValue((CFStringRef)@"AppleInterfaceStyle", kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost));
    if ([value isEqualToString:@"Dark"]) {
        self.darkModeOn = YES;
    } else {
        self.darkModeOn = NO;
    }
}


- (void)itemClicked:(id)sender {
    NSEvent *event = [NSApp currentEvent];
    if([event modifierFlags] & NSControlKeyMask) {
        [[NSApplication sharedApplication] terminate:self];
        return;
    }
    
    
    _darkModeOn = !_darkModeOn; //Change pref
    if (_darkModeOn) {
        CFPreferencesSetValue((CFStringRef)@"AppleInterfaceStyle", @"Dark", kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
    } else {
        CFPreferencesSetValue((CFStringRef)@"AppleInterfaceStyle", NULL, kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
    }
    //update listeners
    dispatch_async(dispatch_get_main_queue(), ^{
        CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), (CFStringRef)@"AppleInterfaceThemeChangedNotification", NULL, NULL, YES);
    });
}


- (void) menuNeedsUpdate: (NSMenu *)menu
{
    NSUInteger flags = ([NSEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
    
    BOOL shouldHideSecretMenu = !(flags == NSAlternateKeyMask);
    
    for (NSMenuItem *item in [menu itemArray]) {
        [item setHidden:shouldHideSecretMenu];
    }
}




- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    self.preferencesController = [[PreferencesController alloc] initWithWindow:self.preferencesWindow];

    [self refreshDarkMode];
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.image = [NSImage imageNamed:@"bat23.png"];
    [_statusItem.image setTemplate:YES];
    [_statusItem setAction:@selector(itemClicked:)];
    

    self.statusItem.menu = self.menu;
    
    Boolean dockStatusIsValid = false;
    Boolean isDockHidden = CFPreferencesGetAppBooleanValue( CFSTR("autohide"), CFSTR("com.apple.dock"), &dockStatusIsValid);
    
    if (dockStatusIsValid) {
        NSLog(@"Dock valid, creating MouseObserver\n");
        self.mouseObserver = [MouseObserver sharedMouseObserver];
    }
    
    if (!isDockHidden) {
        NSLog(@"Dock is NOT hidden. Hiding now ...\n");
        [MouseObserver toggleDock];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [MouseObserver releaseEventManager];
}

@end
