//
//  WBGraphGeo.h
//  SinaWeibo
//
//  Created by cxjwin on 14-4-17.
//  Copyright (c) 2014年 cxjwin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FBGraphObject.h"

@protocol WBGraphGeo <FBGraphObject>

@property (copy, nonatomic) NSString *longitude;

@property (copy, nonatomic) NSString *latitude;

@property (copy, nonatomic) NSString *city;

@property (copy, nonatomic) NSString *province;

@property (copy, nonatomic) NSString *city_name;

@property (copy, nonatomic) NSString *address;

@property (copy, nonatomic) NSString *pinyin;

@property (copy, nonatomic) NSString *more;

@end