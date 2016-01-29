//
//  MouseObserver.m
//  Observer
//
//  Created by Seba on 18.08.15.
//  Copyright (c) 2015 Lunation. All rights reserved.
//

#include <Carbon/Carbon.h>
#include <ApplicationServices/ApplicationServices.h>

#import "MouseObserver.h"

@interface MouseObserver ()

@property (getter=isDockHidden) BOOL dockHidden;
@property NSDictionary *preferences;
@property NSEvent *eventHandler;

@end

void toggleDock() {
    CGEventSourceRef src = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
    
    CGEventRef cmdd = CGEventCreateKeyboardEvent(src, kVK_Command, true);
    CGEventRef cmdu = CGEventCreateKeyboardEvent(src, kVK_Command, false);
    CGEventRef optd = CGEventCreateKeyboardEvent(src, kVK_Option, true);
    CGEventRef optu = CGEventCreateKeyboardEvent(src, kVK_Option, false);
    CGEventRef dd = CGEventCreateKeyboardEvent(src, kVK_ANSI_D, true);
    CGEventRef du = CGEventCreateKeyboardEvent(src, kVK_ANSI_D, false);
    
    CGEventSetFlags(dd, kCGEventFlagMaskCommand ^ kCGEventFlagMaskAlternate);
    CGEventSetFlags(du, kCGEventFlagMaskCommand ^ kCGEventFlagMaskAlternate);
    
    CGEventTapLocation loc = kCGHIDEventTap; // kCGSessionEventTap also works
    CGEventPost(loc, cmdd); //Cmd down
    CGEventPost(loc, optd); //Option down
    CGEventPost(loc, dd);   //D down
    CGEventPost(loc, cmdu); //Cmd up
    CGEventPost(loc, optu); //Option up
    CGEventPost(loc, du);   //D up
    
    
    CFRelease(cmdd);
    CFRelease(cmdu);
    CFRelease(optd);
    CFRelease(optu);
    CFRelease(dd);
    CFRelease(du);
    CFRelease(src);
}



@implementation MouseObserver

+ (void)setPreferences:(NSDictionary *)preferences {
    NSLog(@"");
}

+ (MouseObserver *)sharedMouseObserver {
    static MouseObserver *mouseObserver = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        mouseObserver = [[self alloc] init];
    });
    
    return mouseObserver;
}

+ (void)toggleDock {
    toggleDock();
}

+ (void)releaseEventManager {
    [NSEvent removeMonitor:[MouseObserver sharedMouseObserver].eventHandler];
}

+ (void)setupEventManager {
    unsigned int screenHeight = [[NSScreen mainScreen] frame].size.height;
    
    [MouseObserver sharedMouseObserver].eventHandler = [NSEvent addGlobalMonitorForEventsMatchingMask:NSMouseMovedMask handler:^(NSEvent * mouseEvent) {
        //id eventHandler = [NSEvent addGlobalMonitorForEventsMatchingMask:NSMouseMovedMask handler:^(NSEvent * mouseEvent) {
        int y = [mouseEvent deltaY];
        
        if (y >= 18 && [[MouseObserver sharedMouseObserver] isDockHidden]) {
            toggleDock();
            [MouseObserver sharedMouseObserver].dockHidden = false;
        }
        
        if ([mouseEvent locationInWindow].y > (int)screenHeight/2 && [[MouseObserver sharedMouseObserver] isDockHidden] == false) {
            toggleDock();
            [MouseObserver sharedMouseObserver].dockHidden = true;
        }
    }];

}



- (void)setupMouseEventHandler {
    
    unsigned int screenHeight = [[NSScreen mainScreen] frame].size.height;
    
    
    self.eventHandler = [NSEvent addGlobalMonitorForEventsMatchingMask:NSMouseMovedMask handler:^(NSEvent * mouseEvent) {
    //id eventHandler = [NSEvent addGlobalMonitorForEventsMatchingMask:NSMouseMovedMask handler:^(NSEvent * mouseEvent) {
        int y = [mouseEvent deltaY];
        
        if (y >= 18 && [self isDockHidden]) {
            toggleDock();
            self.dockHidden = false;
        }
        
        if ([mouseEvent locationInWindow].y > (int)screenHeight/2 && [self isDockHidden] == false) {
            toggleDock();
            self.dockHidden = true;
        }
    }];
}

- (instancetype)init {
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    [self setupMouseEventHandler];
    self.dockHidden = true;
    
    return self;
}

- (instancetype)initWithDockStateHidden:(BOOL)hidden {
    if (hidden == 0) {
        toggleDock();
    }
    
    self.dockHidden = true;
    
    [self setupMouseEventHandler];
    
    return [self init];
}

@end
