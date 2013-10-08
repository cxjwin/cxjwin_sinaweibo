//
//  WeiboUser+Builder.h
//  SinaWeibo
//
//  Created by cxjwin on 13-8-29.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import "WeiboUser.h"

@interface WeiboUser (Builder)

- (void)fillInDetailsWithJSONObject:(NSDictionary *)info;

@end
