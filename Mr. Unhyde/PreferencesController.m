//
//  PreferencesController.m
//  Mr. Unhyde
//
//  Created by Eroica on 21.10.23.
//

#import "PreferencesController.h"

@interface PreferencesController ()

@end

@implementation PreferencesController

- (instancetype)init {
    self = [super initWithWindowNibName:@"PreferencesController"];
    
    return self;
    
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)onPreferencesChanged:(id)sender {
    if (self.mouseObserver != nil) {
        [self.mouseObserver setupMouseEventHandler];
    }
}

@end
