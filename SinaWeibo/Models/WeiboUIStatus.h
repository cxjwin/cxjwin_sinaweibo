//
//  WeiboUIStatus.h
//  SinaWeibo
//
//  Created by 蔡 雪钧 on 14-4-13.
//  Copyright (c) 2014年 cxjwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboStatus.h"
#import "ImagesManager.h"

extern CGFloat kTextWidth;

typedef NS_ENUM(NSUInteger, DisplayImageType) {
    DisplayNoImage = 0,
    DisplaySingleImage,
    DisplaySeveralImages,
};

@interface WeiboUIStatus : NSObject

@property (nonatomic, strong) WeiboStatus *status;

@property (nonatomic, assign, readonly) CGFloat contentHeight;

@property (nonatomic, copy, readonly) NSMutableAttributedString *attributedText;

@property (nonatomic, assign, readonly) CGSize textSize;

@property (nonatomic, copy, readonly) NSMutableAttributedString *retweetedAttributedText;

@property (nonatomic, assign, readonly) CGSize retweetedTextSize;

@property (nonatomic, assign, readonly) DisplayImageType displayImageType;

@property (nonatomic, assign, readonly) CGSize displayImageSize;

@property (nonatomic, assign, readonly) ImagesManager *imagesManager;

- (instancetype)initWithStatus:(WeiboStatus *)status;

@end
