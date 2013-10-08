//
//  WeiboUser.h
//  sinaweibo_ios_sdk_demo
//
//  Created by cxjwin on 13-7-9.
//  Copyright (c) 2013年 SINA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeiboUser : NSObject

@property (strong, nonatomic) NSNumber *userId;
@property (copy, nonatomic) NSString *screenName;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *province;
@property (copy, nonatomic) NSString *city;
@property (copy, nonatomic) NSString *location;
@property (copy, nonatomic) NSString *description;
@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString *profileUrl;
@property (copy, nonatomic) NSString *profileImageUrl;
@property (copy, nonatomic) NSString *domain;
@property (copy, nonatomic) NSString *weihao;
@property (copy, nonatomic) NSString *gender;
@property (strong, nonatomic) NSNumber *followersCount;
@property (strong, nonatomic) NSNumber *friendsCount;
@property (strong, nonatomic) NSNumber *statusesCount;
@property (strong, nonatomic) NSNumber *favouritesCount;
@property (copy, nonatomic) NSString *createdAt;
@property (strong, nonatomic) NSNumber *following;
@property (strong, nonatomic) NSNumber *allowAllActMsg;
@property (copy, nonatomic) NSString *remark;
@property (strong, nonatomic) NSNumber *geoEnabled;
@property (strong, nonatomic) NSNumber *verified;
@property (strong, nonatomic) NSDictionary *status;
@property (strong, nonatomic) NSNumber *allowAllComment;
@property (copy, nonatomic) NSString *avatarLarge;
@property (copy, nonatomic) NSString *verifiedReason;
@property (strong, nonatomic) NSNumber *followMe;
@property (strong, nonatomic) NSNumber *onlineStatus;
@property (strong, nonatomic) NSNumber *biFollowersCount;
@property (copy, nonatomic) NSString *lang;

@end
