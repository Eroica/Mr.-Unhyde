//
//  PreferencesController.h
//  Mr. Unhyde
//
//  Created by Eroica on 21.10.23.
//

#import <Cocoa/Cocoa.h>

#import "MouseObserver.h"

NS_ASSUME_NONNULL_BEGIN

@interface PreferencesController : NSWindowController <NSWindowDelegate>

@property MouseObserver *mouseObserver;
@property (nonatomic, strong) NSEvent *localMouseHandler;

@end

NS_ASSUME_NONNULL_END
