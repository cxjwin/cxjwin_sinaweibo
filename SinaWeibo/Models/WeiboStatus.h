//
//  Models.h
//  SinaWeibo
//
//  Created by cxjwin on 13-8-26.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WeiboUser;
@interface WeiboStatus : NSObject

@property (strong, nonatomic) NSNumber *statusId;
@property (copy, nonatomic) NSString *createdAt;
@property (copy, nonatomic) NSString *statusIdstr;
@property (copy, nonatomic) NSString *mid;
@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSString *source;
@property (strong, nonatomic) NSNumber *favorited;
@property (strong, nonatomic) NSNumber *truncated;
@property (strong, nonatomic) NSNumber *repostsCount;
@property (strong, nonatomic) NSNumber *commentsCount;
@property (strong, nonatomic) NSNumber *attitudesCount;
@property (strong, nonatomic) NSDictionary *visible;
@property (strong, nonatomic) NSDictionary *geo;

// pic urls
@property (copy, nonatomic) NSString *thumbnailPic;
@property (copy, nonatomic) NSString *bmiddlePic;
@property (copy, nonatomic) NSString *originalPic;
@property (strong, nonatomic) NSArray *picUrls;

// user
@property (strong, nonatomic) WeiboUser *user;

// retweeted status
@property (strong, nonatomic) WeiboStatus *retweetedStatus;

@end
