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
#import "CoreTextView.h"
#import "SeparateView.h"

NSString *const kShowUserInfoNotification = @"kShowUserInfoNotification";
NSString *const kTouchedURLNotification = @"kTouchedURLNotification";
NSString *const kViewControllerWillPush = @"kViewControllerWillPush";
NSString *const kShowOriginalPicNotification = @"kShowOriginalPicNotification";
NSString *const kThumbnailPicLoadedNotification = @"kThumbnailPicLoadedNotification";
static const int kImageViewBaseTag = 110;

@interface StatusView ()<CoreTextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sourceLabel;
@property (weak, nonatomic) IBOutlet CoreTextView *textView;
@property (weak, nonatomic) IBOutlet SeparateView *separateView;
@property (weak, nonatomic) IBOutlet CoreTextView *reTextView;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *imagesView;

@property (weak, nonatomic) IBOutlet UIButton *reTweetButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *praiseButton;

@property (strong, nonatomic) UIDynamicAnimator *animator;

@end

@implementation StatusView {
    BOOL hasRetweetedStatus;
    NSUInteger picCount;
    CGRect reTweetButtonBounds;
}

- (void)awakeFromNib 
{
    self.textView.delegate = self;
    self.reTextView.delegate = self;
    
    UITapGestureRecognizer *tapAvatar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAvatar:)];
    [self.avatarView addGestureRecognizer:tapAvatar];
    
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
    [self.imageView addGestureRecognizer:tapImage];
    
    for (int i = 0; i < 9; i++) {
        int column = i % 3;
        int row = i / 3;
        UIImageView *aImageView = [[UIImageView alloc] initWithFrame:CGRectMake(64 * column, 64 * row, 64, 64)];
        aImageView.tag = kImageViewBaseTag + i;
        [self.imagesView addSubview:aImageView];
    }
    UITapGestureRecognizer *tapImages = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImages:)];
    [self.imagesView addGestureRecognizer:tapImages];
    
    [self.reTweetButton addTarget:self action:@selector(reTweetStatus:) forControlEvents:UIControlEventTouchUpInside];
    [self.commentButton addTarget:self action:@selector(commentStatus) forControlEvents:UIControlEventTouchUpInside];
    [self.praiseButton addTarget:self action:@selector(praiseStatus) forControlEvents:UIControlEventTouchUpInside];
}

- (void)reTweetStatus:(id)sender
{
    WBLog(@"");
}

- (void)commentStatus
{
    WBLog(@"");
}

- (void)praiseStatus
{
    WBLog(@"");
}

- (void)tapAvatar:(UITapGestureRecognizer *)tap
{
    WBLog(@"");
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowUserInfoNotification object:self.status.user];
}

- (void)tapImages:(UITapGestureRecognizer *)tap
{
    WBLog(@"tapImages!!!");
    if (self.status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowOriginalPicNotification object:self.status];
    }
}

- (void)tapImage:(UITapGestureRecognizer *)tap
{
    WBLog(@"tapImage");
    if (self.status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowOriginalPicNotification object:self.status];
    }
}

- (void)layoutSubviews 
{
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
        WBLog(@"--?? : %f , %f", size.width, size.height);
    }
    
    // tool bar
    top = top + 5;
    self.reTweetButton.frame = CGRectMake(20, top, 40, 16);
    reTweetButtonBounds = self.reTweetButton.bounds;
    self.commentButton.frame = CGRectMake(140, top, 40, 16);
    self.praiseButton.frame = CGRectMake(260, top, 40, 16);
}

- (void)setStatus:(WeiboStatus *)status
{
    _status = status;
    [self refreshViewWithStatus:status];
}

- (void)refreshViewWithStatus:(WeiboStatus *)status
{
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
            [manager downloadWithURL:avatarUrl
                             options:SDWebImageCacheMemoryOnly
                            progress:nil
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                               if (image) {
                                   // do something with image
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       weak_self.avatarView.image = image;
                                   });
                               }
                           }];
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
#ifdef DEBUG
            assert([picURLs count] > 1);
#endif
            picCount = [picURLs count];
            for (int i = 0; i < picCount; i++) {
                NSURL *picURL = [picURLs objectAtIndex:i];
                SDWebImageManager *manager = [SDWebImageManager sharedManager];
                UIImage *image = [manager.imageCache imageFromMemoryCacheForKey:[picURL absoluteString]];
                if (image) {
                    UIImageView *aImageView = (id)[self.imagesView viewWithTag:(kImageViewBaseTag + i)];
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
                                               UIImageView *aImageView = (id)[weak_self.imagesView viewWithTag:(kImageViewBaseTag + block_i)];
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
    
//    WeiboStatus *picStatus = (status.retweetedStatus != nil ? status.retweetedStatus : status);
//    NSURL *picUrl = nil;
//    picCount = [picStatus.picUrls count];
//    if (picCount > 0) {
//        if (picCount == 1) {
//            picUrl = [NSURL URLWithString:[[picStatus.picUrls objectAtIndex:0] objectForKey:@"thumbnail_pic"]];
//        } else {
//            picUrl = [NSURL URLWithString:[[picStatus.picUrls objectAtIndex:0] objectForKey:@"thumbnail_pic"]];
//        }
//    } else {
//        if (picStatus.thumbnailPic) {
//            picCount = 1;
//            picUrl = [NSURL URLWithString:picStatus.thumbnailPic];
//        } else if (picStatus.bmiddlePic) {
//            picCount = 1;
//            picUrl = [NSURL URLWithString:picStatus.bmiddlePic];
//        } else if (picStatus.originalPic) {
//            picCount = 1;
//            picUrl = [NSURL URLWithString:picStatus.originalPic];
//        } else {
//            picCount = 0;
//        }
//    }
//    
//    if (picCount > 0) {
//        self.imagesView.hidden = NO;
//    } else {
//        self.imagesView.hidden = YES;
//    }
    
//    if (picUrl) {
//        SDWebImageManager *manager = [SDWebImageManager sharedManager];
//        UIImage *image = [manager.imageCache imageFromMemoryCacheForKey:[picUrl absoluteString]];
//        if (image) {
//            self.imageView.image = image;
//        } else {
//            self.imageView.image = nil;
//            __weak typeof(self) weak_self = self;
//            [manager downloadWithURL:picUrl
//                             options:SDWebImageCacheMemoryOnly
//                            progress:nil
//                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
//                               if (image) {
//                                   // do something with image
//                                   [[NSNotificationCenter defaultCenter] postNotificationName:kThumbnailPicLoadedNotification object:nil];
//                                   dispatch_async(dispatch_get_main_queue(), ^{
//                                       weak_self.imageView.image = image;
//                                   });
//                               }
//                           }];
//        }
//    }
}

#pragma mark - 
#pragma mark - CoreTextViewDelegate
- (void)touchedURLWithURLStr:(NSString *)urlStr
{
    WBLog(@"url : %@", urlStr);
    [[NSNotificationCenter defaultCenter] postNotificationName:kTouchedURLNotification object:urlStr];
}

@end