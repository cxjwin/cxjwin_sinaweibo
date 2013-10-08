//
//  StatusCellView.h
//  SinaWeibo
//
//  Created by cxjwin on 13-8-27.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/SDWebImageManager.h>

extern NSString *const kShowUserInfoNotification;
extern NSString *const kTouchedURLNotification;
extern NSString *const kShowOriginalPicNotification;
extern NSString *const kThumbnailPicLoadedNotification;

@class WeiboStatus;
@interface StatusView : UIView

@property (strong, nonatomic) WeiboStatus *status;

@end
