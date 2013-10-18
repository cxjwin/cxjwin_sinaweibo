//
//  SinaWeibo.h
//  SinaWeibo
//
//  Created by cxjwin on 13-8-19.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SinaWeiboCommunicator.h"
#import "SinaWeiboAuthorizeView.h"

extern NSString *const kSinaWeiboDidLogInNotification;
extern NSString *const kSinaWeiboDidLogOutNotification;
extern NSString *const kSinaWeiboLogInDidCancelNotification;
extern NSString *const kSinaWeiboLogInDidFailNotification;
extern NSString *const kSinaWeiboAccessTokenInvalidOrExpired;
extern NSString *const kWeiboUserInfoDidUpdateNotification;

#define kNoExpiresIn -1

@protocol SinaWeiboDelegate;
@class WeiboUser;
@interface SinaWeiboManager : NSObject <
    SinaWeiboAuthorizeViewDelegate,
NSURLSessionDelegate,
NSURLSessionTaskDelegate, 
NSURLSessionDataDelegate>

// account info
@property (copy, nonatomic) NSString *accessToken;
@property (copy, nonatomic) NSString *userID;
@property (assign, nonatomic) long long expiresIn;

// current user
@property (strong, nonatomic) WeiboUser *user;

// weibo communicator
@property (strong, nonatomic) SinaWeiboCommunicator *communicator;

+(SinaWeiboManager *)defaultManager;

- (void)loginIn;
- (void)loginOut;

- (BOOL)isLoggedIn;
- (BOOL)isAuthorizeExpired;
- (BOOL)isAuthorizeValid;

- (void)getCurrentUserInfo;

@end
