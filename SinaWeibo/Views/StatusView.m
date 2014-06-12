//
//  StatusCellView.m
//  SinaWeibo
//
//  Created by cxjwin on 13-8-27.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "StatusView.h"
#import "WeiboStatus+Builder.h"
#import "WeiboUser+Builder.h"

NSString *const kViewControllerWillPush = @"kViewControllerWillPush";
NSString *const kShowOriginalPicNotification = @"kShowOriginalPicNotification";
NSString *const kThumbnailPicLoadedNotification = @"kThumbnailPicLoadedNotification";

NSString *const kRetweetStatusNotification = @"kRetweetStatusNotification";
NSString *const kCommentStatusNotification = @"kCommentStatusNotification";
NSString *const kPraiseStatusNotification = @"kPraiseStatusNotification";
NSString *const kShowUserInfoNotification = @"kShowUserInfoNotification";
NSString *const kLinkToURLNotification = @"kLinkToURLNotification";

static const int kImageViewBaseTag = 110;

@interface StatusView ()

@end

@implementation StatusView
{
    BOOL hasRetweetedStatus;
    NSUInteger picCount;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initCommon];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initCommon];
    }
    
    return self;
}

- (void)initCommon {
    self.avatarView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.avatarView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapAvatar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAvatar:)];
    [self.avatarView addGestureRecognizer:tapAvatar];
    [self addSubview:self.avatarView];
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nameLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:self.nameLabel];
    
    self.sourceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.sourceLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:self.sourceLabel];
    
    self.textView = [[CoreTextView alloc] initWithFrame:CGRectZero];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.delegate = self;
    [self addSubview:self.textView];
    
    self.separateView = [[SeparateView alloc] initWithFrame:CGRectZero];
    [self addSubview:self.separateView];
    
    self.reTextView = [[CoreTextView alloc] initWithFrame:CGRectZero];
    self.reTextView.backgroundColor = [UIColor clearColor];
    self.reTextView.delegate = self;
    [self addSubview:self.reTextView];
    
    self.imagesView = [[UIView alloc] initWithFrame:CGRectZero];
    for (int i = 0; i < 9; i++) {
        int column = i % 3;
        int row = i / 3;
        UIImageView *aImageView = [[UIImageView alloc] initWithFrame:CGRectMake(64 * column, 64 * row, 64, 64)];
        aImageView.tag = kImageViewBaseTag + i;
        [self.imagesView addSubview:aImageView];
    }
    
    UITapGestureRecognizer *tapImages = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImages:)];
    [self.imagesView addGestureRecognizer:tapImages];
    [self addSubview:self.imagesView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
    [self.imageView addGestureRecognizer:tapImage];
    [self addSubview:self.imageView];
    
    self.retweetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.retweetButton setTitle:@"转发" forState:UIControlStateNormal];
    [self.retweetButton addTarget:self action:@selector(retweetStatus) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.retweetButton];
    
    self.commentButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.commentButton setTitle:@"评论" forState:UIControlStateNormal];
    [self.commentButton addTarget:self action:@selector(commentStatus) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.commentButton];
    
    self.praiseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.praiseButton setTitle:@"赞" forState:UIControlStateNormal];
    [self.praiseButton addTarget:self action:@selector(praiseStatus) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.praiseButton];
}

// 转发
- (void)retweetStatus {
    [[NSNotificationCenter defaultCenter] postNotificationName:kRetweetStatusNotification object:self.status];
}

// 评论
- (void)commentStatus {
    [[NSNotificationCenter defaultCenter] postNotificationName:kCommentStatusNotification object:self.status];
}

// 点赞
- (void)praiseStatus {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPraiseStatusNotification object:self.status];
}

// 点击头像
- (void)tapAvatar:(UITapGestureRecognizer *)tap {
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowUserInfoNotification object:self.status.user];
}

// 点击图片
- (void)tapImages:(UITapGestureRecognizer *)tap {
    //
}

// 点击图片
- (void)tapImage:(UITapGestureRecognizer *)tap {
    //
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // header view
    self.avatarView.frame = CGRectMake(6, 6, 36, 36);
    self.nameLabel.frame = CGRectMake(48, 7, 150, 15);
    self.sourceLabel.frame = CGRectMake(48, 27, 150, 15);
    
    // stuatus text view
    CGFloat top = 48 + 3;
    self.textView.frame = CGRectMake(20, top, kContentTextWidth, [self.status.contentTextSize CGSizeValue].height);
    [self.textView setNeedsDisplay];
    top = top + [self.status.contentTextSize CGSizeValue].height + 2;
    
    if (self.status.retweetedStatus) {
        // separate view
        top = top + 2;
        self.separateView.frame = CGRectMake(15, top, CGRectGetWidth(self.frame) - 30, 16);
        top = top + 16 + 2;
        
        // retweeted status text view
        top = top + 3;
        self.reTextView.frame = CGRectMake(20, top, kContentTextWidth, [self.status.retweetedStatus.contentTextSize CGSizeValue].height);
        top = top + [self.status.retweetedStatus.contentTextSize CGSizeValue].height + 3;
    }
    
    // pic view
    if (picCount > 1) {
        top = top + 3;
        CGSize size = [self.status.previewImageSize CGSizeValue];
        CGFloat x = (CGRectGetWidth(self.frame) - size.width) * 0.5;
        self.imagesView.frame = CGRectMake(x, top, size.width, size.height);
        top = top + size.height + 3;
    } else if (picCount == 1) {
        top = top + 3;
        CGSize size = [self.status.previewImageSize CGSizeValue];
        CGFloat x = (CGRectGetWidth(self.frame) - size.width) * 0.5;
        self.imageView.frame = CGRectMake(x, top, size.width, size.height);
        top = top + size.height + 3;
    }
    
    // tool bar
    top = top + 5;
    self.retweetButton.frame = CGRectMake(20, top, 40, 16);
    self.commentButton.frame = CGRectMake(140, top, 40, 16);
    self.praiseButton.frame = CGRectMake(260, top, 40, 16);
}

- (void)setStatus:(WeiboStatus *)status {
    if (_status != status) {
        _status = status;
    }
    
    [self refreshViewWithStatus:status];
}

- (void)refreshViewWithStatus:(WeiboStatus *)status {
    NSURL *avatarUrl = nil;
    
    if (status.user.profileImageUrl) {
        avatarUrl = [NSURL URLWithString:status.user.profileImageUrl];
    }
    
    if (avatarUrl) {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        UIImage *image = [manager.imageCache imageFromMemoryCacheForKey:[avatarUrl absoluteString]];
        if (image) {
            self.avatarView.image = image;
        } else {
            self.avatarView.image = nil;
            
            __weak typeof(self) weak_self = self;
            void (^completed)(UIImage *, NSError *, SDImageCacheType, BOOL) = ^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weak_self.avatarView.image = image;
                    });
                }
            };
            
            [manager downloadWithURL:avatarUrl options:SDWebImageCacheMemoryOnly progress:nil completed:completed];
        }
    }
    
    self.nameLabel.text = status.user.screenName;
    self.sourceLabel.text = status.source;
    
    self.textView.attributedString = [status attributedText];
    if (status.retweetedStatus) {
        self.separateView.hidden = NO;
        self.reTextView.hidden = NO;
        self.reTextView.attributedString = status.retweetedStatus.attributedText;
    } else {
        self.separateView.hidden = YES;
        self.reTextView.hidden = YES;
    }
    
    id result = [status pictureURLInStatus];
    if (result) {
        if ([result isKindOfClass:[NSMutableArray class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.hidden = YES;
                self.imagesView.hidden = NO;
            });
            
            NSMutableArray *picURLs = result;
            NSAssert([picURLs count] > 1, @"pic count > 1");
            picCount = [picURLs count];
            for (int i = 0; i < picCount; i++) {
                NSURL *picURL = [picURLs objectAtIndex:i];
                SDWebImageManager *manager = [SDWebImageManager sharedManager];
                UIImage *image = [manager.imageCache imageFromMemoryCacheForKey:[picURL absoluteString]];
                if (image) {
                    UIImageView *aImageView = (id)[self.imagesView viewWithTag : (kImageViewBaseTag + i)];
                    aImageView.image = image;
                } else {
                    __weak typeof(self) weak_self = self;
                    
                    __block int block_i = i;
                    [manager downloadWithURL:picURL
                                     options:SDWebImageCacheMemoryOnly
                                    progress:nil
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                       if (image) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               UIImageView *aImageView = (id)[weak_self.imagesView viewWithTag: (kImageViewBaseTag + block_i)];
                                               aImageView.image = image;
                                           });
                                       }
                                   }];
                }
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.hidden = NO;
                self.imagesView.hidden = YES;
            });
            
            
            picCount = 1;
            NSURL *picURL = result;
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            UIImage *image = [manager.imageCache imageFromMemoryCacheForKey:[picURL absoluteString]];
            if (image) {
                self.imageView.image = image;
            } else {
                self.imageView.image = nil;
                __weak typeof(self) weak_self = self;
                
                [manager downloadWithURL:picURL
                                 options:SDWebImageCacheMemoryOnly
                                progress:nil
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                   if (image) {
                                       // do something with image
                                       [[NSNotificationCenter defaultCenter] postNotificationName:kThumbnailPicLoadedNotification object:nil];
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           weak_self.imageView.image = image;
                                           [weak_self setNeedsLayout];
                                       });
                                   }
                               }];
            }
        }
    } else {
        self.imageView.hidden = YES;
        self.imagesView.hidden = YES;
    }
    
    [self setNeedsLayout];
}

#pragma mark -
#pragma mark - CoreTextViewDelegate
- (void)touchedURLWithURLStr:(NSString *)urlStr {
    [[NSNotificationCenter defaultCenter] postNotificationName:kLinkToURLNotification object:[urlStr copy]];
}

@end
