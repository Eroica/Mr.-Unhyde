//
//  MouseObserver.m
//  Mr. Unhyde
//
//  Created by Eroica on 22.10.23.
//

#include <Carbon/Carbon.h>
#include <ApplicationServices/ApplicationServices.h>

#import "MouseObserver.h"

NSDictionary *MOUSE_POSITION_MULTIPLIER = @{
    @"75 %": @0.75,
    @"50 %": @0.5,
    @"25 %": @0.25
};

@interface MouseObserver ()

@property (getter=isDockHidden) BOOL dockHidden;
@property NSEvent *eventHandler;

@end

@implementation MouseObserver {
    CGEventSourceRef _eventSource;
    
    CGEventRef cmdd;
    CGEventRef cmdu;
    CGEventRef optd;
    CGEventRef optu;
    CGEventRef dd;
    CGEventRef du;
}

- (instancetype)init {
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self->_eventSource = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
    
    self->cmdd = CGEventCreateKeyboardEvent(self->_eventSource, kVK_Command, true);
    self->cmdu = CGEventCreateKeyboardEvent(self->_eventSource, kVK_Command, false);
    self->optd = CGEventCreateKeyboardEvent(self->_eventSource, kVK_Option, true);
    self->optu = CGEventCreateKeyboardEvent(self->_eventSource, kVK_Option, false);
    self->dd = CGEventCreateKeyboardEvent(self->_eventSource, kVK_ANSI_D, true);
    self->du = CGEventCreateKeyboardEvent(self->_eventSource, kVK_ANSI_D, false);
    
    CGEventSetFlags(self->dd, kCGEventFlagMaskCommand ^ kCGEventFlagMaskAlternate);
    CGEventSetFlags(self->du, kCGEventFlagMaskCommand ^ kCGEventFlagMaskAlternate);
    
    return self;
}


- (instancetype)initWithDockStateHidden:(BOOL)hidden {
    self = [self init];
    
    if (hidden == YES) {
        [self toggleDock];
    }
    
    _dockHidden = hidden;
    [self setupMouseEventHandler];
    
    return self;
}


- (void)onDestroy {
    CFRelease(cmdd);
    CFRelease(cmdu);
    CFRelease(optd);
    CFRelease(optu);
    CFRelease(dd);
    CFRelease(du);
    CFRelease(_eventSource);
    [NSEvent removeMonitor:self.eventHandler];
}


- (void)setupMouseEventHandler {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    double positionMultiplier = [[MOUSE_POSITION_MULTIPLIER objectForKey:[defaults objectForKey:@"mousePosition"]] doubleValue];
    
    [self rebindWith:[defaults boolForKey:@"isMousePosition"]
       andMouseSpeed:[defaults boolForKey:@"isMouseSpeed"]
         forPosition:positionMultiplier
            andSpeed:1];
}


- (void)rebindWith:(BOOL)isMousePosition andMouseSpeed:(BOOL)isMouseSpeed forPosition:(double)position andSpeed:(int)speed {
    unsigned int screenHeight = [[NSScreen mainScreen] frame].size.height;
    
    if (self.eventHandler != nil) {
        [NSEvent removeMonitor:self.eventHandler];
    }
    
    self.eventHandler = [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskMouseMoved handler:^(NSEvent * mouseEvent) {
        if (self.isDockHidden
            && isMousePosition && (int)[NSEvent mouseLocation].y < screenHeight * position
            && [mouseEvent deltaY] > 2) {
            [self toggleDock];
            self.dockHidden = false;
            return;
        }
        
        if (!self.isDockHidden && isMousePosition && (int)[NSEvent mouseLocation].y > screenHeight * position) {
            [self toggleDock];
            self.dockHidden = true;
            return;
        }
    }];
}


- (void)toggleDock {
    CGEventPost(kCGHIDEventTap, cmdd);
    CGEventPost(kCGHIDEventTap, optd);
    CGEventPost(kCGHIDEventTap, dd);
    CGEventPost(kCGHIDEventTap, cmdu);
    CGEventPost(kCGHIDEventTap, optu);
    CGEventPost(kCGHIDEventTap, du);
}

@end
