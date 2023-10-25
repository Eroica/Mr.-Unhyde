//
//  MouseObserver.m
//  Mr. Unhyde
//
//  Created by Eroica on 22.10.23.
//

#include <Carbon/Carbon.h>
#include <ApplicationServices/ApplicationServices.h>
#import <Foundation/Foundation.h>

#import "MouseObserver.h"

NSDictionary *MOUSE_POSITION_MULTIPLIER = @{
    @"75 %": @0.75,
    @"50 %": @0.5,
    @"25 %": @0.25
};

dispatch_source_t CreateDebounceDispatchTimer(double debounceTime, dispatch_queue_t queue, dispatch_block_t block) {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    if (timer) {
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, debounceTime * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, (1ull * NSEC_PER_SEC) / 10);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    
    return timer;
}

@interface MouseObserver ()

@property NSEvent *eventHandler;
@property (strong) dispatch_source_t debounceTimer;

@end

@implementation MouseObserver {
    NSDictionary *MOUSE_SPEED;
    
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
    
    MOUSE_SPEED = @{
        @1: @10,
        @2: @25,
        @3: @75,
        @4: @125,
        @5: @200,
    };
    
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
    double mouseSpeed = [[MOUSE_SPEED objectForKey:[defaults objectForKey:@"mouseSpeed"]] integerValue];
    
    [self rebindWith:[defaults boolForKey:@"isMousePosition"]
       andMouseSpeed:[defaults boolForKey:@"isMouseSpeed"]
         forPosition:positionMultiplier
            andSpeed:mouseSpeed];
}


- (void)rebindWith:(BOOL)isMousePosition andMouseSpeed:(BOOL)isMouseSpeed forPosition:(double)position andSpeed:(int)speed {
    NSLog(@"Setting up observer with %i, %i, %f, %i", isMousePosition, isMouseSpeed, position, speed);
    
    unsigned int screenHeight = [[NSScreen mainScreen] frame].size.height;
    
    if (self.eventHandler != nil) {
        [NSEvent removeMonitor:self.eventHandler];
    }
    
    double __block oldPos = [NSEvent mouseLocation].y;
    double __block newPos = [NSEvent mouseLocation].y;
    
    self.eventHandler = [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskMouseMoved handler:^(NSEvent * mouseEvent) {
        if (self.debounceTimer != nil) {
            dispatch_source_cancel(self.debounceTimer);
            self.debounceTimer = nil;
        }
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        double secondsToThrottle = 0.0005f;
        self.debounceTimer = CreateDebounceDispatchTimer(secondsToThrottle, queue, ^{
            newPos = [NSEvent mouseLocation].y;
            double yAccel = fabs(oldPos - newPos);
            oldPos = newPos;
            
            if (self.isDockHidden
                && isMousePosition && (int)[NSEvent mouseLocation].y < screenHeight * position
                && yAccel > speed) {
                [self toggleDock];
                self.dockHidden = false;
                return;
            }
            
            if (!self.isDockHidden && isMousePosition && (int)[NSEvent mouseLocation].y > screenHeight * position) {
                [self toggleDock];
                self.dockHidden = true;
            }
        });
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
