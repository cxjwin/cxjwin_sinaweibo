//
//  AppDelegateTests.m
//  SinaWeibo
//
//  Created by cxjwin on 13-8-19.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "AppDelegate.h"

@interface AppDelegateTests : XCTestCase

@end

@implementation AppDelegateTests

- (void)setUp {
	[super setUp];
	// Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown {
	// Put teardown code here; it will be run once, after the last test case.
	[super tearDown];
}

- (void)testApplicationDidFinishLaunching {
	AppDelegate *delegate = [AppDelegate sharedDelegate];
	
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
	UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
	
	id appDelegateMock = [OCMockObject partialMockForObject:delegate];
}

@end
