//
//  PreferencesController.m
//  Mr. Unhyde
//
//  Created by Eroica on 21.10.23.
//

#import "PreferencesController.h"

@interface PreferencesController ()

@property (nonatomic, nullable, strong) NSEvent *localMouseHandler;

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


- (IBAction)onPreferencesChanged:(id)sender {
    [self.mouseObserver updateWithUserDefaults];
}


- (IBAction)showWindow:(id)sender
{
    [super showWindow:sender];
    if (self.localMouseHandler == nil) {
        self.localMouseHandler = [self.mouseObserver setupLocalEventHandler];
    }
}


- (void)windowWillClose:(NSNotification *)notification {
    [NSEvent removeMonitor:self.localMouseHandler];
    self.localMouseHandler = nil;
}

@end
