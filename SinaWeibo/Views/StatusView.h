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

@interface StatusView : UIView <CoreTextViewDelegate>

// 头像
@property (nonatomic, strong) UIImageView *avatarView;
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

// 单张图片
@property (nonatomic, strong) UIImageView *imageView;
// 多张图片
@property (nonatomic, strong) UIView *imagesView;

// 转发按钮
@property (nonatomic, strong) UIButton *retweetButton;
// 评论按钮
@property (nonatomic, strong) UIButton *commentButton;
// 点赞
@property (nonatomic, strong) UIButton *praiseButton;

// 微博状态
@property (nonatomic, strong) WeiboStatus *status;

@end
