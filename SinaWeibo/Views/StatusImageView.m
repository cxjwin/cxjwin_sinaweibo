//
//  StatusImageView.m
//  SinaWeibo
//
//  Created by cxjwin on 6/13/14.
//  Copyright (c) 2014 cxjwin. All rights reserved.
//

#import <SDWebImage/SDWebImageManager.h>
#import "StatusImageView.h"

@interface URLImageView : UIImageView

@property (nonatomic, copy) NSString *URLString;

@end

@interface StatusImageView ()

@property (nonatomic, retain) NSMutableArray *imageViews;

@end

@implementation StatusImageView {
	CGSize displaySize;
}

const NSUInteger kMaxRowCount = 3;
const NSUInteger kMaxColumnCount = 3;

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code
	}

	return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setURLStrings:(NSArray *)URLStrings {
	if (_URLStrings != URLStrings) {
		_URLStrings = [URLStrings copy];
	}

	// remove all image view
	for (UIView *view in self.imageViews) {
		[view removeFromSuperview];
	}

	displaySize = CGSizeZero;
	self.imageViews = nil;

	// add image view
	NSUInteger count = [_URLStrings count];
	if (_URLStrings && count > 0) {
		self.imageViews = [NSMutableArray arrayWithCapacity:count];

		// single image
		if (count == 1) {
			displaySize = CGSizeMake(100, 100);
			URLImageView *imageView = [[URLImageView alloc] initWithFrame:(CGRect) {CGPointZero, displaySize}];
			imageView.URLString = [URLStrings firstObject];
			[self addSubview:imageView];
			[self.imageViews addObject:imageView];
		}
		// multiple images
		else {
			static CGFloat singleImageWidth = 64.0;

			CGFloat x = 0;
			CGFloat y = 0;

			for (NSUInteger i = 0; i < count; ++i) {
				URLImageView *imageView = [[URLImageView alloc] initWithFrame:CGRectMake(x, y, singleImageWidth, singleImageWidth)];
				imageView.URLString = [URLStrings objectAtIndex:i];
				[self addSubview:imageView];
				[self.imageViews addObject:imageView];

				x += singleImageWidth;
				if (x >= singleImageWidth * kMaxRowCount) {
					x = 0;
					y += singleImageWidth;
				}
			}

			displaySize = CGSizeMake(singleImageWidth * kMaxRowCount, MIN(y + singleImageWidth, singleImageWidth * kMaxColumnCount));
		}
	}
}

- (CGSize)intrinsicContentSize {
	return displaySize;
}

- (CGSize)displaySize {
	return displaySize;
}

@end

@import QuartzCore;

@implementation URLImageView

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.contentMode = UIViewContentModeScaleAspectFit;
	}

	return self;
}

- (void)setURLString:(NSString *)URLString {
	if (_URLString != URLString) {
		_URLString = [URLString copy];
	}

	NSURL *avatarUrl = nil;
	if (_URLString) {
		avatarUrl = [NSURL URLWithString:_URLString];
	}

	if (avatarUrl) {
		SDWebImageManager *manager = [SDWebImageManager sharedManager];
		UIImage *image = [manager.imageCache imageFromMemoryCacheForKey:[avatarUrl absoluteString]];
		if (image) {
			self.image = image;
		} else {
			self.image = nil;

			__weak typeof(self) weakSelf = self;

			void (^completed)(UIImage *, NSError *, SDImageCacheType, BOOL) = ^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
				if (image) {
					NSAssert([NSThread isMainThread], @"is main thread");
					dispatch_async(dispatch_get_main_queue(), ^{
						[weakSelf exchangeImage:image];
					});
				}
			};

			[manager downloadWithURL:avatarUrl options:SDWebImageCacheMemoryOnly progress:nil completed:completed];
		}
	}
}

- (void)exchangeImage:(UIImage *)image {
	CATransition *transition = [CATransition animation];
	transition.duration = 0.3;
	transition.type = kCATransitionFade;
	self.image = image;
	[self.layer addAnimation:transition forKey:nil];
}

@end
