//
//  MouseObserver.h
//  Mr. Unhyde
//
//  Created by Eroica on 22.10.23.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MouseObserver : NSObject

- (instancetype) init NS_DESIGNATED_INITIALIZER;
- (instancetype) initWithDockStateHidden: (BOOL)hidden;
- (void)setupMouseEventHandler;
- (void)toggleDock;
- (void)onDestroy;

@end

NS_ASSUME_NONNULL_END
