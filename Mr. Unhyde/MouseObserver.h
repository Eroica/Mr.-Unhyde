//
//  MouseObserver.h
//  Mr. Unhyde
//
//  Created by Eroica on 22.10.23.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MouseObserver : NSObject

@property (getter=isPaused) BOOL paused;
@property (getter=isDockHidden) BOOL dockHidden;

- (instancetype) init NS_DESIGNATED_INITIALIZER;
- (void)onDestroy;
- (void)setupMouseEventHandler;
- (NSEvent *)setupLocalEventHandler;
- (void)toggleDock;

@end

NS_ASSUME_NONNULL_END
