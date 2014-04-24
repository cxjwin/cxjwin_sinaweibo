//
//  WBGraphUser.h
//  SinaWeibo
//
//  Created by cxjwin on 14-4-17.
//  Copyright (c) 2014年 cxjwin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FBGraphObject.h"
#import "WBGraphStatus.h"

const NSString *class_key = @"class";

@protocol WBGraphStatus;

@protocol WBGraphUser <FBGraphObject>

@property (strong, nonatomic) NSNumber *id;

@property (copy, nonatomic) NSString *idstr;

// class is a method of NSObject
// use |objectForKey:| (key is @"class") instead
// @property (strong, nonatomic) NSNumber *class;

@property (copy, nonatomic) NSString *screen_name;

@property (copy, nonatomic) NSString *name;

@property (copy, nonatomic) NSString *province;

@property (copy, nonatomic) NSString *city;

@property (copy, nonatomic) NSString *location;

@property (copy, nonatomic) NSString * description;

@property (copy, nonatomic) NSString *url;

@property (copy, nonatomic) NSString *profile_image_url;

@property (copy, nonatomic) NSString *profile_url;

@property (copy, nonatomic) NSString *domain;

@property (copy, nonatomic) NSString *weihao;

@property (copy, nonatomic) NSString *gender;

@property (strong, nonatomic) NSNumber *followers_count;

@property (strong, nonatomic) NSNumber *friends_count;

@property (strong, nonatomic) NSNumber *favourites_count;

@property (copy, nonatomic) NSString *created_at;

@property (strong, nonatomic) NSNumber *following;

@property (strong, nonatomic) NSNumber *allow_all_act_msg;

@property (strong, nonatomic) NSNumber *geo_enabled;

@property (strong, nonatomic) NSNumber *verified;

@property (strong, nonatomic) NSNumber *verified_type;

@property (strong, nonatomic) id<WBGraphStatus> status;

@property (strong, nonatomic) NSNumber *ptype;

@property (strong, nonatomic) NSNumber *allow_all_comment;

@property (copy, nonatomic) NSString *avatar_large;

@property (copy, nonatomic) NSString *avatar_hd;

@property (copy, nonatomic) NSString *verified_reason;

@property (strong, nonatomic) NSNumber *follow_me;

@property (strong, nonatomic) NSNumber *online_status;

@property (strong, nonatomic) NSNumber *bi_followers_count;

@property (copy, nonatomic) NSString *lang;

@property (strong, nonatomic) NSNumber *star;

@end
