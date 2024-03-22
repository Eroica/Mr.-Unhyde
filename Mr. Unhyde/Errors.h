//
//  InitializationError.h
//  Mr. Unhyde
//
//  Created by Eroica on 22.03.24.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

void showErrorDialog(NSString *errorMessage);

@interface InitializationError : NSException

- (instancetype)initWithMessage:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
