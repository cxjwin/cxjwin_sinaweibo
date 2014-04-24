//
//  WBGraphObjectTests.m
//  SinaWeibo
//
//  Created by cxjwin on 14-4-17.
//  Copyright (c) 2014年 cxjwin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FBGraphObject.h"
#import "WBGraphStatus.h"
#import "WBGraphUser.h"
#import "WBGraphGeo.h"

NSString *const path1 = @"/Users/cxjwin/Desktop/WorkSpace/Github/cxjwin_sinaweibo/SinaWeiboTests/Tests/ModelsTests/test_one_status.txt";
NSString *const path2 = @"/Users/cxjwin/Desktop/WorkSpace/Github/cxjwin_sinaweibo/SinaWeiboTests/Tests/ModelsTests/test_twenty_status.txt";
NSString *const path3 = @"/Users/cxjwin/Desktop/WorkSpace/Github/cxjwin_sinaweibo/SinaWeiboTests/Tests/ModelsTests/test_user.txt";

@interface WBGraphObjectTests : XCTestCase

@property (strong, nonatomic) NSDictionary *statusDict;

@property (strong, nonatomic) NSDictionary *userDict;

@property (strong, nonatomic) NSDictionary *statusesDict;

@end

@implementation WBGraphObjectTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	
	// status data
	{
		NSData *data = [NSData dataWithContentsOfFile:path1];
		NSError *error = nil;
		self.statusDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
		if (!self.statusDict) {
			NSLog(@"%@", [error debugDescription]);
		}
	}
	
	// statuses data
	{
		NSData *data = [NSData dataWithContentsOfFile:path2];
		NSError *error = nil;
		self.statusesDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
		if (!self.statusesDict) {
			NSLog(@"%@", [error debugDescription]);
		}
	}
	
	// user data
	{
		NSData *data = [NSData dataWithContentsOfFile:path3];
		NSError *error = nil;
		self.userDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
		if (!self.userDict) {
			NSLog(@"%@", [error debugDescription]);
		}
	}
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGraphObjectWrapping
{
    NSMutableDictionary<FBGraphObject> *obj = [FBGraphObject graphObjectWrappingDictionary:self.statusDict];
	XCTAssertNotNil(obj, @"obj not be nil");
	
	obj = [FBGraphObject graphObjectWrappingDictionary:self.userDict];
	XCTAssertNotNil(obj, @"obj not be nil");

	obj = [FBGraphObject graphObjectWrappingDictionary:self.statusesDict];
	XCTAssertNotNil(obj, @"obj not be nil");
}

- (void)testGraphStatusWrapping {
	id<WBGraphStatus> obj = (id<WBGraphStatus>)[FBGraphObject graphObjectWrappingDictionary:self.statusDict];
	XCTAssertNotNil(obj, @"obj is't nil");
	
	XCTAssertNotNil([obj idstr], @"id is't nil");
	NSLog(@"id : %@", [obj idstr]);
	
	XCTAssertNotNil([obj created_at], @"created_at is't nil");
	NSLog(@"created_at : %@", [obj created_at]);

	XCTAssertNotNil([obj retweeted_status], @"retweeted_status is't nil");
	NSLog(@"retweeted_status : %@", [obj retweeted_status]);
	
	XCTAssertEqual([obj geo], (id)[NSNull null], @"geo is <null> but not nil");
	
	XCTAssertNotNil([obj visible], @"visible is't nil");
}

- (void)testGraphUserWrapping {
	id<WBGraphUser> obj = (id<WBGraphUser>)[FBGraphObject graphObjectWrappingDictionary:self.userDict];
	
	XCTAssertNotNil([obj id], @"id is't nil");
	
	XCTAssertNotNil([obj objectForKey:class_key], @"class is't nil");
	NSLog(@"class : %@", [obj objectForKey:class_key]);
}

@end
