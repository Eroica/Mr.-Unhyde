//
//  MouseObserverTests.m
//  Mr. Unhyde Tests
//
//  Created by Eroica on 31.03.24.
//

#import <XCTest/XCTest.h>

#import "MouseObserver.h"

@interface MouseObserverTests : XCTestCase

@end

@implementation MouseObserverTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testShouldShowDock {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCTAssertFalse(ShouldShowDockUsingMousePosition(NO, YES, YES, 500, 100, 450, 150));
    XCTAssertFalse(ShouldShowDockUsingMousePosition(NO, YES, YES, 500, 100, 550, 150));

    XCTAssertTrue(ShouldShowDockUsingMousePosition(YES, YES, YES, 500, 100, 450, 150));
    XCTAssertFalse(ShouldShowDockUsingMousePosition(YES, YES, YES, 500, 100, 550, 150));
}

- (void)testShouldHideDock {
    XCTAssertFalse(ShouldHideDockUsingMousePosition(YES, YES, YES, 500, 100, 550, 150));
    XCTAssertFalse(ShouldHideDockUsingMousePosition(YES, YES, YES, 500, 100, 450, 150));

    XCTAssertTrue(ShouldHideDockUsingMousePosition(NO, YES, YES, 500, 100, 550, 150));
    XCTAssertFalse(ShouldHideDockUsingMousePosition(NO, YES, YES, 500, 100, 450, 150));
}

@end
