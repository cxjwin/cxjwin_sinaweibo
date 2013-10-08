//
//  AppDelegateTests.m
//  SinaWeibo
//
//  Created by cxjwin on 13-8-19.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AppDelegate.h"

@interface AppDelegateTests : XCTestCase

@end

@implementation AppDelegateTests {
  __weak AppDelegate *delegate;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
  delegate = (id)[[UIApplication sharedApplication] delegate];
  XCTAssertNotNil(delegate, @"delegate is a singleton");
}

- (void)tearDown
{
  delegate = nil;
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testApplicationDidFinishLaunching {
  BOOL launched = [delegate application:[UIApplication sharedApplication] didFinishLaunchingWithOptions:nil];
  XCTAssertTrue(launched, @"application launched");
}

@end
