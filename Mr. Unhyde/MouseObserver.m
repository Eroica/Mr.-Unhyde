//
//  MouseObserver.m
//  Mr. Unhyde
//
//  Created by Eroica on 22.10.23.
//

#include <Carbon/Carbon.h>
#import <Foundation/Foundation.h>

#import "MouseObserver.h"

double SECONDS_TO_THROTTLE = 0.0005f;

NSDictionary *MOUSE_POSITION_MULTIPLIER = @{
    @"75 %": @0.75,
    @"50 %": @0.5,
    @"25 %": @0.25
};

NSDictionary *MOUSE_SPEED = @{
    @"1": @10,
    @"2": @50,
    @"3": @100,
    @"4": @150,
    @"5": @250,
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
    NSInteger _minimumHeight;
    CGEventSourceRef _eventSource;
    
    CGEventRef cmdd;
    CGEventRef cmdu;
    CGEventRef optd;
    CGEventRef optu;
    CGEventRef dd;
    CGEventRef du;
}

- (instancetype)init {
    return [self initWithUserDefaults];
}


- (instancetype)initWithUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    double isMousePosition = [defaults boolForKey:@"isMousePosition"];
    double isMouseSpeed = [defaults boolForKey:@"isMouseSpeed"];
    double positionMultiplier = [[MOUSE_POSITION_MULTIPLIER objectForKey:[defaults objectForKey:@"mousePosition"]] doubleValue];
    NSInteger minimumSpeed = [[MOUSE_SPEED objectForKey:[[defaults objectForKey:@"mouseSpeed"] stringValue]] integerValue];

    return [self initWithUsingMousePosition:isMousePosition
                            usingMouseSpeed:isMouseSpeed
                         forMinimumPosition:positionMultiplier
                               minimumSpeed:minimumSpeed];
}


- (instancetype) initWithUsingMousePosition:(BOOL)mousePosition
                            usingMouseSpeed:(BOOL)mouseSpeed
                         forMinimumPosition:(double)minimumPosition
                               minimumSpeed:(NSInteger)minimumSpeed {
    self = [super init];

    if (!self) {
        return nil;
    }

    self.mousePosition = mousePosition;
    self.mouseSpeed = mouseSpeed;
    self.minimumPosition = minimumPosition;
    self.minimumSpeed = minimumSpeed;

    unsigned int screenHeight = [[NSScreen mainScreen] frame].size.height;
    _minimumHeight = screenHeight * self.minimumPosition;

    self->_eventSource = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);

    self->cmdd = CGEventCreateKeyboardEvent(self->_eventSource, kVK_Command, true);
    self->cmdu = CGEventCreateKeyboardEvent(self->_eventSource, kVK_Command, false);
    self->optd = CGEventCreateKeyboardEvent(self->_eventSource, kVK_Option, true);
    self->optu = CGEventCreateKeyboardEvent(self->_eventSource, kVK_Option, false);
    self->dd = CGEventCreateKeyboardEvent(self->_eventSource, kVK_ANSI_D, true);
    self->du = CGEventCreateKeyboardEvent(self->_eventSource, kVK_ANSI_D, false);

    CGEventSetFlags(self->dd, kCGEventFlagMaskCommand ^ kCGEventFlagMaskAlternate);
    CGEventSetFlags(self->du, kCGEventFlagMaskCommand ^ kCGEventFlagMaskAlternate);

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


- (void)updateWithUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.mousePosition = [defaults boolForKey:@"isMousePosition"];
    self.mouseSpeed = [defaults boolForKey:@"isMouseSpeed"];
    self.minimumPosition = [[MOUSE_POSITION_MULTIPLIER objectForKey:[defaults objectForKey:@"mousePosition"]] doubleValue];
    self.minimumSpeed = [[MOUSE_SPEED objectForKey:[[defaults objectForKey:@"mouseSpeed"] stringValue]] integerValue];

    unsigned int screenHeight = [[NSScreen mainScreen] frame].size.height;
    _minimumHeight = screenHeight * self.minimumPosition;

    NSLog(@"Updating values with %i, %i, %f, %li", self.mousePosition, self.mouseSpeed, self.minimumPosition, self.minimumSpeed);
}


- (void)setupMouseEventHandler {
    NSLog(@"Setting up observer with %i, %i, %f, %li", self.mousePosition, self.mouseSpeed, self.minimumPosition, self.minimumSpeed);

    double __block oldPosition = [NSEvent mouseLocation].y;
    double __block newPosition = [NSEvent mouseLocation].y;

    self.eventHandler = [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskMouseMoved handler:^(NSEvent * mouseEvent) {
        if (self.debounceTimer != nil) {
            dispatch_source_cancel(self.debounceTimer);
            self.debounceTimer = nil;
        }

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.debounceTimer = CreateDebounceDispatchTimer(SECONDS_TO_THROTTLE, queue, ^{
            if (self.isPaused) {
                return;
            }

            newPosition = [NSEvent mouseLocation].y;
            double deltaY = fabs(oldPosition - newPosition);
            oldPosition = newPosition;

            if (ShouldShowDockUsingMousePosition(self.dockHidden, self.mousePosition, self.mouseSpeed, self->_minimumHeight, self.minimumSpeed, newPosition, deltaY)) {
                [self toggleDock];
                self.dockHidden = false;
                return;
            }

            if (ShouldHideDockUsingMousePosition(self.dockHidden, self.mousePosition, self.mouseSpeed, self->_minimumHeight, self.minimumSpeed, newPosition, deltaY)) {
                [self toggleDock];
                self.dockHidden = true;
            }
        });
    }];
}


- (NSEvent *)setupLocalEventHandler {
    NSLog(@"Setting up local observer with %i, %i, %f, %li", self.mousePosition, self.mouseSpeed, self.minimumPosition, self.minimumSpeed);

    double __block oldPosition = [NSEvent mouseLocation].y;
    double __block newPosition = [NSEvent mouseLocation].y;

    return [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskMouseMoved handler:^NSEvent * _Nullable(NSEvent * _Nonnull event) {
        if (self.debounceTimer != nil) {
            dispatch_source_cancel(self.debounceTimer);
            self.debounceTimer = nil;
        }

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.debounceTimer = CreateDebounceDispatchTimer(SECONDS_TO_THROTTLE, queue, ^{
            newPosition = [NSEvent mouseLocation].y;
            double deltaY = fabs(oldPosition - newPosition);
            oldPosition = newPosition;

            if (ShouldShowDockUsingMousePosition(self.dockHidden, self.mousePosition, self.mouseSpeed, self->_minimumHeight, self.minimumSpeed, newPosition, deltaY)) {
                [self toggleDock];
                self.dockHidden = false;
                return;
            }

            if (ShouldHideDockUsingMousePosition(self.dockHidden, self.mousePosition, self.mouseSpeed, self->_minimumHeight, self.minimumSpeed, newPosition, deltaY)) {
                [self toggleDock];
                self.dockHidden = true;
            }
        });
        
        return event;
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
