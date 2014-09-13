//
//  StatusCellView.m
//  SinaWeibo
//
//  Created by cxjwin on 13-8-27.
//  Copyright (c) 2013 cxjwin. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "StatusView.h"
#import "WeiboStatus+Builder.h"
#import "WeiboUser+Builder.h"
#import "NSMutableAttributedString+Weibo.h"
#import "BridgingView.h"

NSString *const kViewControllerWillPush = @"kViewControllerWillPush";
NSString *const kShowOriginalPicNotification = @"kShowOriginalPicNotification";
NSString *const kThumbnailPicLoadedNotification = @"kThumbnailPicLoadedNotification";

NSString *const kRetweetStatusNotification = @"kRetweetStatusNotification";
NSString *const kCommentStatusNotification = @"kCommentStatusNotification";
NSString *const kPraiseStatusNotification = @"kPraiseStatusNotification";
NSString *const kShowUserInfoNotification = @"kShowUserInfoNotification";
NSString *const kLinkToURLNotification = @"kLinkToURLNotification";

// ---------------------------------------------------------------------------------------------------------------
@interface StatusView ()

@end

@implementation StatusView {
	BOOL didSetupConstraints;
    BOOL hasRetweetedStatus;
	NSUInteger picCount;
	
	NSArray *retweetedContacts;
}

+ (CGFloat)contentHeightWithStatus:(WeiboStatus *)status {
	CGFloat height = 0;
	
	// avatar & name & source
	height += 9;
	height += 36;
	
	// text
	height += 9;
	CGSize adjustSize = [status.attributedText adjustSizeWithMaxWidth:kContentTextWidth];
	height += adjustSize.height;
	
	// retweeted status text
	WeiboStatus *retweetedStatus = status.retweetedStatus;
	if (retweetedStatus) {
		height += 9;
		// separate view
		height += 20;
		
		// text
		height += 9;
		CGSize adjustSize = [retweetedStatus.attributedText adjustSizeWithMaxWidth:kContentTextWidth];
		height += adjustSize.height;
	}
	
	// image
	CGSize previewImageSize = [status.previewImageSize CGSizeValue];
	if (!CGSizeEqualToSize(previewImageSize, CGSizeZero)) {
		height += 9;
		height += previewImageSize.height;
	}
	
	// buttons
	height += 9;
	height += 30;
	height += 9;

	return ceil(height);
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
    self.avatarView = [[AvatarView alloc] initWithFrame:CGRectZero];
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
	
    self.imageView = [[StatusImageView alloc] initWithFrame:CGRectZero];
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

- (void)layoutSubviews {
    [super layoutSubviews];
	
	CGFloat top = 9;
    // header view
    self.avatarView.frame = CGRectMake(6, top, 36, 36);
    self.nameLabel.frame = CGRectMake(48, top, 150, 15);
    self.sourceLabel.frame = CGRectMake(48, top + 18, 150, 15);
	top += 36;
	
    // stuatus text view
    top += 9;
    self.textView.frame = CGRectMake(20, top, kContentTextWidth, [self.status.contentTextSize CGSizeValue].height);
    [self.textView setNeedsDisplay];
    top = top + [self.status.contentTextSize CGSizeValue].height + 2;
    
    if (self.status.retweetedStatus) {
        // separate view
        top += 9;
        self.separateView.frame = CGRectMake(15, top, CGRectGetWidth(self.frame) - 30, 20);
        top += 20;
        
        // retweeted status text view
        top += 9;
        self.reTextView.frame = CGRectMake(20, top, kContentTextWidth, [self.status.retweetedStatus.contentTextSize CGSizeValue].height);
        top += [self.status.retweetedStatus.contentTextSize CGSizeValue].height;
    }
    
    // image view
	if (!CGSizeEqualToSize(self.imageView.displaySize, CGSizeZero)) {
		top += 9;
		CGSize size = self.imageView.displaySize;
		CGFloat x = (CGRectGetWidth(self.frame) - size.width) * 0.5;
		self.imageView.frame = CGRectMake(x, top, size.width, size.height);
		top += size.height;
	}
	
    // tool bar
    top = top + 9;
    self.retweetButton.frame = CGRectMake(20, top, 40, 16);
    self.commentButton.frame = CGRectMake(140, top, 40, 16);
    self.praiseButton.frame = CGRectMake(260, top, 40, 16);
}

- (void)updateConstraints {
	[super updateConstraints];
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

- (void)setStatus:(WeiboStatus *)status {
    if (_status != status) {
        _status = status;
    }
	
    [self refreshViewWithStatus:status];
}

- (void)refreshViewWithStatus:(WeiboStatus *)status {
	NSString *profileImageUrl = status.user.profileImageUrl;
    if (status.user.profileImageUrl) {
		self.avatarView.URLString = profileImageUrl;
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
	
	NSArray *strings = [status pictureURLStringsInStatus];
	self.imageView.URLStrings = strings;
	
	[self setNeedsLayout];
}

#pragma mark -
#pragma mark - CoreTextViewDelegate
- (void)touchedURLWithURLStr:(NSString *)urlStr {
    [[NSNotificationCenter defaultCenter] postNotificationName:kLinkToURLNotification object:[urlStr copy]];
}

@end
