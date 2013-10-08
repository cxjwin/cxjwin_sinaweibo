//
//  RequestUtils.h
//  SinaWeibo
//
//  Created by cxjwin on 13-8-20.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SinaWeiboConstants.h"

#define kAppKey             @"1372038092"
#define kAppSecret          @"4740bf09be7e855f7813c69b0a040382"
#define kAppRedirectURI     @"http://www.cnblogs.com/cxjwin/"

@interface RequestUtils : NSObject

+ (NSString *)getParamValueFromURL:(NSString*)url paramName:(NSString *)paramName;

+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params;

+ (BOOL)catchErrorInfoFromResultJSON:(NSDictionary *)dict error:(NSError **)error;

@end
