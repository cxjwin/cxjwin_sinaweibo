//
//  RequestUtilsTests.m
//  SinaWeibo
//
//  Created by cxjwin on 13-8-20.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RequestUtils.h"
#import "SinaWeiboConstants.h"

#define kAppKey             @"1372038092"
#define kAppSecret          @"4740bf09be7e855f7813c69b0a040382"
#define kAppRedirectURI     @"http://"

@interface RequestUtilsTests : XCTestCase

@end

@implementation RequestUtilsTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testSerializeURL {
  // escaped_value
  NSString *escaped_str = @"!*'();:@&=+$,/?%#[]";
  NSString *escaped_value =
  CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, /* allocator */
                                                            (CFStringRef)escaped_str,
                                                            NULL, /* charactersToLeaveUnescaped */
                                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                            kCFStringEncodingUTF8));
  
  // serializeURL
  // 参数有
  NSDictionary *params = @{@"client_id" : kAppKey, @"count" : @"20"};
  NSString *urlStr = [RequestUtils serializeURL:kSinaWeiboWebAuthURL params:params];
  NSString *cvtStr =
  CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, 
                                                                            (CFStringRef)urlStr,
                                                                            (CFStringRef)escaped_value,
                                                                            kCFStringEncodingUTF8));
  
  NSString *resultStrOne = [NSString stringWithFormat:@"%@?client_id=%@&count=%d", kSinaWeiboWebAuthURL, kAppKey, 20];
  NSString *resultStrTwo = [NSString stringWithFormat:@"%@?count=%d&client_id=%@", kSinaWeiboWebAuthURL, 20, kAppKey];
  // 顺序是不确定的
  BOOL equal = ([cvtStr isEqualToString:resultStrOne] || [cvtStr isEqualToString:resultStrTwo]);
  
  XCTAssertTrue(equal, @"serializeURL ok...");
}

- (void)testgetParamValueFromUrl {
  NSString *urlStr = @"https://open.weibo.cn/2/oauth2/authorize?client_id=123050457758183&redirect_uri=http://www.example.com/response&response_type=code";
  NSString *valueOne = [RequestUtils getParamValueFromURL:urlStr paramName:@"client_id"];
  XCTAssertEqualObjects(valueOne, @"123050457758183", @"client_id=123050457758183");
  NSString *valueTwo = [RequestUtils getParamValueFromURL:urlStr paramName:@"redirect_uri"];
  XCTAssertEqualObjects(valueTwo, @"http://www.example.com/response", @"redirect_uri=http://www.example.com/response");
  NSString *valueThree = [RequestUtils getParamValueFromURL:urlStr paramName:@"response_type"];
  XCTAssertEqualObjects(valueThree, @"code", @"response_type=code");
}

- (void)testCatchErrorInfoFromResultJSON {
  NSDictionary *dict = @{@"error": @"miss required parameter (id), see doc for more info.",
                         @"error_code": [NSNumber numberWithInt:10016],
                         @"request": @"/2/statuses/show.json"};
  NSError *error = nil;
  BOOL catched = [RequestUtils catchErrorInfoFromResultJSON:dict error:&error];
  XCTAssertTrue(catched, @"has error");
  XCTAssertNotNil(error, @"error not nil");
}
@end
