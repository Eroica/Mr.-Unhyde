//
//  PreferencesController.m
//  Observer
//
//  Created by Seba on 18.08.15.
//  Copyright (c) 2015 Lunation. All rights reserved.
//

#import "PreferencesController.h"

typedef NS_ENUM(NSUInteger, screenHeightSteps) {
    SCREEN_ZERO,
    SCREEN_FULL,
    SCREEN_HALF,
    SCREEN_THIRD,
    SCREEN_QUARTER,
    SCREEN_TWO_THIRDS,
    SCREEN_THREE_QUARTERS
};


@interface PreferencesController () {
    
}
@property (weak) IBOutlet NSButton *mousePositionCheckbox;
@property (weak) IBOutlet NSButton *mouseSpeedCheckbox;
@property (weak) IBOutlet NSPopUpButton *mousePositionCombobox;
@property (weak) IBOutlet NSSlider *mouseSpeedSlider;

@end

@implementation PreferencesController
- (IBAction)setMousePosition:(id)sender {
    NSLog(@"Has been set to %ld\n", (long)[self.mousePositionCheckbox integerValue]);
}
- (IBAction)setMouseSpeed:(id)sender {
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)checkMousePosition:(id)sender {
    if (self.mousePositionCheckbox.integerValue == 0) {
        NSLog(@"Doing sth");
        [MouseObserver releaseEventManager];
    }
}

- (IBAction)checkMouseSpeed:(id)sender {
}


@end
