//
//  MouseObserver.h
//  Observer
//
//  Created by Seba on 18.08.15.
//  Copyright (c) 2015 Lunation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MouseObserver : NSObject

- (instancetype) init NS_DESIGNATED_INITIALIZER;
- (instancetype) initWithDockStateHidden: (BOOL)hidden;

+ (void)setPreferences:(NSDictionary *)preferences;
+ (MouseObserver *)sharedMouseObserver;
+ (void)toggleDock;
+ (void)releaseEventManager;

@end
