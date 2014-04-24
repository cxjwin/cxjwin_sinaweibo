//
//  WBGraphStatus.h
//  SinaWeibo
//
//  Created by cxjwin on 14-4-17.
//  Copyright (c) 2014年 cxjwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBGraphObject.h"
#import "WBGraphUser.h"
#import "WBGraphGeo.h"

@protocol WBGraphVisible;
@protocol WBGraphStatus;

@protocol WBGraphStatus <FBGraphObject>

@property (strong, nonatomic) NSNumber *id;

@property (copy, nonatomic) NSString *created_at;

@property (copy, nonatomic) NSString *mid;

@property (copy, nonatomic) NSString *idstr;

@property (copy, nonatomic) NSString *text;

@property (copy, nonatomic) NSString *source;

@property (strong, nonatomic) NSNumber *favorited;

@property (strong, nonatomic) NSNumber *truncated;

@property (strong, nonatomic) NSArray *pic_urls;

@property (strong, nonatomic) id<WBGraphGeo> geo;

@property (strong, nonatomic) id<WBGraphUser> user;

@property (strong, nonatomic) id<WBGraphStatus> retweeted_status;

@property (strong, nonatomic) NSNumber *reposts_count;

@property (strong, nonatomic) NSNumber *comments_count;

@property (strong, nonatomic) NSNumber *attitudes_count;

@property (strong, nonatomic) id<WBGraphVisible> visible;

@end

@protocol WBGraphVisible <FBGraphObject>

@property (strong, nonatomic) NSNumber *type;

@property (strong, nonatomic) NSNumber *list_id;

@end

@protocol WBGraphStatuses <FBGraphObject>

@property (strong, nonatomic) NSMutableArray *statuses;

@end


