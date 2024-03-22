//
//  InitializationError.m
//  Mr. Unhyde
//
//  Created by Eroica on 22.03.24.
//

#import "Errors.h"

NSErrorDomain const MrUnhydeErrorDomain = @"earth.groundctrl.MrUnhyde";

void showErrorDialog(NSString *errorMessage) {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Error"];
    [alert setInformativeText:errorMessage];
    [alert addButtonWithTitle:@"Quit"];
    [alert runModal];
}

@implementation InitializationError

- (instancetype)initWithMessage:(NSString *)message {
    self = [super initWithName:@"InitalizationError" reason:message userInfo:nil];

    return self;
}

@end
