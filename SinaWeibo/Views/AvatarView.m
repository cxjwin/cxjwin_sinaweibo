//
//  AvatarView.m
//  SinaWeibo
//
//  Created by cxjwin on 6/13/14.
//  Copyright (c) 2014 cxjwin. All rights reserved.
//


#import <SDWebImage/SDWebImageManager.h>
#import "AvatarView.h"

@implementation AvatarView

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		//
	}

	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code
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
						weakSelf.image = image;
					});
				}
			};
			
			[manager downloadWithURL:avatarUrl options:SDWebImageCacheMemoryOnly progress:nil completed:completed];
		}
	}
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
