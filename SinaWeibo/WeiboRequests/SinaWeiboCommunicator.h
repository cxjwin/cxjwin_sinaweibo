//
//  SinaWeiboRequests.h
//  SinaWeibo
//
//  Created by cxjwin on 13-8-19.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
    #define kOneKilobyte 1024lu
    #define kOneMegabyte 1048576lu
    #define kOneGigaByte 1073741824lu
#else
    #define kOneKilobyte 1024u
    #define kOneMegabyte 1048576u
    #define kOneGigaByte 1073741824u
#endif

extern NSString *const kWeiboBackgroundSessionIdentifier;
extern NSTimeInterval kDefaultTimeoutIntervalForResource;

typedef void(^DataCompletionHandler)(NSData *data, NSURLResponse *response, NSError *error);
typedef void(^DownloadCompletionHandler)(NSURL *location, NSURLResponse *response, NSError *error);

@interface SinaWeiboCommunicator : NSObject <
    NSURLSessionDelegate,
    NSURLSessionTaskDelegate, 
    NSURLSessionDataDelegate,
    NSURLSessionDownloadDelegate, 
    NSURLConnectionDelegate>

@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (strong, nonatomic) NSURLSession *defaultSession;
@property (strong, nonatomic) NSURLSession *backgroundSession;
@property (strong, nonatomic) NSURLSession *ephemeralSession;
@property (strong, nonatomic) NSMutableDictionary *completionHandlerDictionary;

// get methods
- (void)getAccessTokenWithAuthorizationCode:(NSString *)code completionHandler:(DataCompletionHandler)handler;
- (void)getUserInfoWithID:(NSString *)userID completionHandler:(DataCompletionHandler)handler;
- (void)getWeiboStatusesWithPage:(int)page completionHandler:(DataCompletionHandler)handler;
// download methods
- (void)downloadImageWithURL:(NSURL *)URL downloadCompletionHandler:(DataCompletionHandler)handler;

@end
