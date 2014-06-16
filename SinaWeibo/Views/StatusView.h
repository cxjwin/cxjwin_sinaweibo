//
//  StatusCellView.h
//  SinaWeibo
//
//  Created by cxjwin on 13-8-27.
//  Copyright (c) 2013 cxjwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/SDWebImageManager.h>
#import "CoreTextView.h"
#import "SeparateView.h"

extern NSString *const kShowOriginalPicNotification;
extern NSString *const kThumbnailPicLoadedNotification;

// Notification object is WeiboStatus
extern NSString *const kRetweetStatusNotification;
// Notification object is WeiboStatus
extern NSString *const kCommentStatusNotification;
// Notification object is WeiboStatus
extern NSString *const kPraiseStatusNotification;
// Notification object is WeiboUser
extern NSString *const kShowUserInfoNotification;
// Notification object url String
extern NSString *const kLinkToURLNotification;

@class WeiboStatus;
@class AvatarView;
@class StatusImageView;

@interface StatusView : UIView <CoreTextViewDelegate>

// model
// 微博状态
@property (nonatomic, strong) WeiboStatus *status;

// sub views
// 头像
@property (nonatomic, strong) AvatarView *avatarView;
// 昵称
@property (nonatomic, strong) UILabel *nameLabel;
// 来源平台
@property (nonatomic, strong) UILabel *sourceLabel;

// 微博内容
@property (nonatomic, strong) CoreTextView *textView;
// 分割线
@property (nonatomic, strong) SeparateView *separateView;
// 转发内容
@property (nonatomic, strong) CoreTextView *reTextView;

// 图片
@property (nonatomic, strong) StatusImageView *imageView;

// 转发按钮
@property (nonatomic, strong) UIButton *retweetButton;
// 评论按钮
@property (nonatomic, strong) UIButton *commentButton;
// 点赞按钮
@property (nonatomic, strong) UIButton *praiseButton;

+ (CGFloat)contentHeightWithStatus:(WeiboStatus *)status;

@end
