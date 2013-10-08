//
//  RequestUtils.m
//  SinaWeibo
//
//  Created by cxjwin on 13-8-20.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import "RequestUtils.h"

@implementation RequestUtils

+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params {
    NSURL *parsedURL = [NSURL URLWithString:baseURL];
    NSString *queryPrefix = parsedURL.query ? @"&" : @"?";
    
    NSMutableArray *pairs = [NSMutableArray array];
    for (NSString *key in params.allKeys) {
        id value = [params objectForKey:key];
#ifdef DEBUG
        assert([value isKindOfClass:[NSString class]]);
#endif
        if ([value isKindOfClass:[NSString class]]) {
            // 转义特殊字符
            NSString *escaped_value =
            CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, /* allocator */
                                                                      (CFStringRef)[params objectForKey:key],
                                                                      NULL, /* charactersToLeaveUnescaped */
                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                      kCFStringEncodingUTF8));
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
        }
    }
    NSString *query = [pairs componentsJoinedByString:@"&"];
    return [NSString stringWithFormat:@"%@%@%@", baseURL, queryPrefix, query];
}

+ (NSString *)getParamValueFromURL:(NSString *)url paramName:(NSString *)paramName {
    if ([paramName hasSuffix:@"="] == NO) {
        paramName = [NSString stringWithFormat:@"%@=", paramName];
    }
    NSString * str = nil;
    NSRange start = [url rangeOfString:paramName];
    if (start.location != NSNotFound) {
        // confirm that the parameter is not a partial name match
        unichar c = '?';
        if (start.location != 0) {
            c = [url characterAtIndex:start.location - 1];
        }
        if (c == '?' || c == '&' || c == '#') {
            NSRange end = [[url substringFromIndex:start.location+start.length] rangeOfString:@"&"];
            NSUInteger offset = start.location+start.length;
            str = (end.location == NSNotFound ?
                   [url substringFromIndex:offset] :
                   [url substringWithRange:NSMakeRange(offset, end.location)]);
            str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
    }
    return str;
}

+ (BOOL)catchErrorInfoFromResultJSON:(NSDictionary *)dict error:(NSError **)error {
    NSNumber *error_code = [dict objectForKey:@"error_code"];
    if (error_code > 0 && error) {
        NSString *error_description = [dict objectForKey:@"error_description"];
        NSDictionary *userInfo = nil;
        if (error_description) {
            userInfo = @{@"error" : dict,
                         NSLocalizedDescriptionKey : error_description};
        }
        *error = [NSError errorWithDomain:kSinaWeiboSDKErrorDomain 
                                     code:[error_code intValue]
                                 userInfo:userInfo];
        return YES;
    } else {
        return NO;
    }
}

@end
