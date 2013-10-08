//
//  SinaWeibo.m
//  SinaWeibo
//
//  Created by cxjwin on 13-8-19.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import "SinaWeiboManager.h"
#import "RequestUtils.h"
#import "SinaWeiboCommunicator.h"
#import "WeiboUser+Builder.h"
#import "DatabaseManager.h"

NSString *const kSinaWeiboDidLogInNotification = @"kSinaWeiboDidLogInNotification";
NSString *const kSinaWeiboDidLogOutNotification = @"kSinaWeiboDidLogOutNotification";
NSString *const kSinaWeiboLogInDidCancelNotification = @"kSinaWeiboLogInDidCancelNotification";
NSString *const kSinaWeiboLogInDidFailNotification = @"kSinaWeiboLogInDidFailNotification";
NSString *const kSinaWeiboAccessTokenInvalidOrExpired = @"kSinaWeiboAccessTokenInvalidOrExpired";
NSString *const kWeiboUserInfoDidUpdateNotification = @"kWeiboUserInfoDidUpdateNotification";

@implementation SinaWeiboManager

static SinaWeiboManager *singleton = nil;
+ (SinaWeiboManager *)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[SinaWeiboManager alloc] init];
    });
    return singleton;
}

- (id)init {
    self = [super init];
    if (self) {
        self.user = [[WeiboUser alloc] init];
        self.communicator = [[SinaWeiboCommunicator alloc] init];
        [self loginAccountFromDB];
    }
    return self;
}

- (void)loginAccountFromDB {
    FMDatabase *database = [[DatabaseManager defaultManager] database];
    NSString *sql = [NSString stringWithFormat:@"select * from login_account order by login_time desc limit 1;"];
    FMResultSet *resultSet = [database executeQuery:sql];
    while ([resultSet next]) {
        self.userID = [resultSet stringForColumnIndex:0];
        self.accessToken = [resultSet stringForColumnIndex:1];
        self.expiresIn = [resultSet longLongIntForColumnIndex:2];
    }
}

- (BOOL)saveAccountToDB {
    FMDatabase *database = [[DatabaseManager defaultManager] database];
    NSString *sql = [NSString stringWithFormat:@"select * from login_account where user_id=%@;", self.userID];
    FMResultSet *resultSet = [database executeQuery:sql];
    BOOL success = NO;
    if ([resultSet next]) {
        success = [self updateAccountToDB];
    } else {
        success = [self addAccountToDB];
    }
    return success;
}

- (BOOL)updateAccountToDB {
    BOOL success = NO;
    FMDatabase *database = [[DatabaseManager defaultManager] database];
    NSString *sql = 
    [NSString stringWithFormat:@"update login_account set expires_in=%lld, login_time=%lld where user_id=%@",
     self.expiresIn,
     (long long)[[NSDate date] timeIntervalSince1970],
     self.userID];
    success = [database executeUpdate:sql];
    return success;
}

- (BOOL)addAccountToDB {
    BOOL success = NO;
    FMDatabase *database = [[DatabaseManager defaultManager] database];
    NSString *sql = @"insert into login_account (user_id, access_token, expires_in, login_time) values (?,?,?,?);";
    NSNumber *loginTime = [NSNumber numberWithLongLong:(long long)[[NSDate date] timeIntervalSince1970]];
    success = [database executeUpdate:sql withArgumentsInArray:@[self.userID, self.accessToken, @(self.expiresIn), loginTime]];
    return success;
}

// check whether weibo is valid
- (BOOL)isLoggedIn {
    BOOL success = NO;
    if (self.userID && self.accessToken && (self.expiresIn >= 0)) {
        success = YES;
    }
    return success;
}

- (BOOL)isAuthorizeExpired {
    long long now = (long long)[[NSDate date] timeIntervalSince1970];
    return (now < self.expiresIn);
}

- (BOOL)isAuthorizeValid {
    return ([self isLoggedIn] && ![self isAuthorizeExpired]);
}

#pragma mark - 
#pragma mark - loginIn/loginOut
- (void)loginIn {
    if ([self isAuthorizeValid]) {
        [self updateAccountToDB];
        [self getCurrentUserInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSinaWeiboDidLogInNotification object:nil];
    } else {
        [self removeAuthData];
        // 通过网页授权
        [self openSinaWeiboAuthorizeView];
    }
}

- (void)loginOut {
    [self removeAuthData];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSinaWeiboDidLogOutNotification object:nil];
}

#pragma mark - Private methods
- (void)removeAuthData {
    self.accessToken = nil;
    self.userID = nil;
    self.expiresIn = kNoExpiresIn;
    
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* sinaweiboCookies = 
    [cookies cookiesForURL:[NSURL URLWithString:@"https://open.weibo.cn"]];
    for (NSHTTPCookie* cookie in sinaweiboCookies) {
        [cookies deleteCookie:cookie];
    }
}

- (void)openSinaWeiboAuthorizeView {
    NSDictionary *params = @{@"client_id" : kAppKey,
                             @"response_type" : @"code",
                             @"redirect_uri" : kAppRedirectURI,
                             @"display" : @"mobile"};
    SinaWeiboAuthorizeView *authorizeView =
    [[SinaWeiboAuthorizeView alloc] initWithAuthParams:params delegate:self];
    [authorizeView show];
}

- (void)logInDidFinishWithAuthInfo:(NSDictionary *)authInfo {
    NSString *access_token = [authInfo objectForKey:@"access_token"];
    NSString *uid = [authInfo objectForKey:@"uid"];
    NSString *expires_in = [authInfo objectForKey:@"expires_in"];
    if (access_token && uid) {
        self.accessToken = access_token;
        self.userID = uid;
        if (expires_in) {
            self.expiresIn = [expires_in longLongValue];
        }
        [self saveAccountToDB];
        [self getCurrentUserInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSinaWeiboDidLogInNotification object:nil];
    }
}

#pragma mark - 
#pragma mark - SinaWeiboAuthorizeViewDelegate
- (void)authorizeView:(SinaWeiboAuthorizeView *)authView
didRecieveAuthorizationCode:(NSString *)code 
{
    __weak typeof(self) weak_self = self;
    void (^completionHandler)(NSData *data, NSURLResponse *response, NSError *error)
    = ^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *_error = nil;
        BOOL hasError = NO;
        if (data) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:NSJSONReadingMutableContainers 
                                                                     error:&_error];
            if (result) {
                hasError = [RequestUtils catchErrorInfoFromResultJSON:result error:&_error];
                if (hasError == NO) {
                    [weak_self logInDidFinishWithAuthInfo:result];
                }
            } else {
                hasError = YES;
            }
        } else {
            _error = error;
            hasError = YES;
        }
        if (hasError) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kSinaWeiboLogInDidFailNotification object:_error];
        }
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.communicator getAccessTokenWithAuthorizationCode:code completionHandler:completionHandler];
    });
}

- (void)authorizeView:(SinaWeiboAuthorizeView *)authView
 didFailWithErrorInfo:(NSDictionary *)errorInfo 
{
    NSString *error_code = [errorInfo objectForKey:@"error_code"];
    if ([error_code isEqualToString:@"21330"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSinaWeiboLogInDidCancelNotification object:nil];
    } else {
        NSString *error_description = [errorInfo objectForKey:@"error_description"];
        NSDictionary *userInfo = @{@"error" : errorInfo,
                                   NSLocalizedDescriptionKey : error_description};
        NSError *error = [NSError errorWithDomain:kSinaWeiboSDKErrorDomain 
                                             code:[error_code intValue]
                                         userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSinaWeiboLogInDidFailNotification object:error];
    }
}

- (void)authorizeViewDidCancel:(SinaWeiboAuthorizeView *)authView 
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSinaWeiboLogInDidCancelNotification object:nil];
}

- (void)getCurrentUserInfo 
{
    __weak typeof(self) weak_self = self;
    DataCompletionHandler completionHandler
    = ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            WBLog(@"net error : %@", [error localizedDescription]);
            double delayInSeconds = 30.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                [weak_self getCurrentUserInfo];
            });
        } else {
            BOOL hasError = NO;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:NSJSONReadingMutableContainers 
                                                                     error:nil];
            if (result) {
                hasError = [RequestUtils catchErrorInfoFromResultJSON:result error:nil];
            } else {
                hasError = YES;
            }
            if (hasError) {
                double delayInSeconds = 30.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                    [weak_self getCurrentUserInfo];
                });
            } else {
                [weak_self.user fillInDetailsWithJSONObject:result];
                [[NSNotificationCenter defaultCenter] postNotificationName:kWeiboUserInfoDidUpdateNotification object:nil];
            }
        }
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.communicator getUserInfoWithID:self.userID completionHandler:completionHandler];
    });
}

@end