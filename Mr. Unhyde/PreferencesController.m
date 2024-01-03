//
//  PreferencesController.m
//  Mr. Unhyde
//
//  Created by Eroica on 21.10.23.
//

#import "PreferencesController.h"

@interface PreferencesController ()
    @property (nonatomic, strong) NSEvent *localMouseHandler;
@end

@implementation PreferencesController

- (instancetype)init {
    self = [super initWithWindowNibName:@"Preferences"];
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    self.window.delegate = self;
}

- (void)showWindow:(id)sender {
    [super showWindow:sender];

    // TODO Lookup injection
    self.localMouseHandler = [self.mouseObserver setupLocalEventHandler];
}

- (BOOL)windowShouldClose:(NSWindow *)sender {
    [NSEvent removeMonitor:self.localMouseHandler];
    
    return YES;
}

- (IBAction)onPreferencesChanged:(id)sender {
    if (self.mouseObserver != nil) {
        [self.mouseObserver setupMouseEventHandler];
        [NSEvent removeMonitor:self.localMouseHandler];
        self.localMouseHandler = [self.mouseObserver setupLocalEventHandler];
    }
}

@end
