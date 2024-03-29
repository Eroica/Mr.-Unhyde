//
//  MouseObserver.h
//  Mr. Unhyde
//
//  Created by Eroica on 22.10.23.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MouseObserver : NSObject

@property BOOL mousePosition;
@property BOOL mouseSpeed;
@property double minimumPosition;
@property NSInteger minimumSpeed;

@property (getter=isPaused) BOOL paused;
@property (getter=isDockHidden) BOOL dockHidden;

- (instancetype) init;
- (instancetype) initWithUserDefaults;
- (instancetype) initWithUsingMousePosition:(BOOL)mousePosition
                            usingMouseSpeed:(BOOL)mouseSpeed
                         forMinimumPosition:(double)minimumPosition
                               minimumSpeed:(NSInteger)minimumSpeed NS_DESIGNATED_INITIALIZER;
- (void)onDestroy;
- (void)updateWithUserDefaults;
- (NSEvent *)setupLocalEventHandler;
- (void)toggleDock;

@end

NS_ASSUME_NONNULL_END
