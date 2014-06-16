//
//  WeiboStatus+Builder.h
//  SinaWeibo
//
//  Created by cxjwin on 13-8-26.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "WeiboStatus.h"

@class NSManagedObject;

@interface WeiboStatus (Builder)

@property (copy, nonatomic) NSMutableAttributedString *attributedText;
@property (retain, nonatomic) NSValue *contentTextSize;
@property (retain, nonatomic) NSValue *previewImageSize;

+ (NSMutableArray *)statusesFromJSONData:(NSData *)data error:(NSError **)error;
+ (NSMutableArray *)statusesWithPreviewImageSizeFromJSONData:(NSData *)data error:(NSError **)error;

- (void)fillInDetailsWithJSONObject:(NSDictionary *)info;

- (id)pictureURLInStatus;

- (NSArray *)pictureURLStringsInStatus;

@end
