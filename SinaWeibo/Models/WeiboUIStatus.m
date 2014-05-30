//
//  WeiboUIStatus.m
//  SinaWeibo
//
//  Created by 蔡 雪钧 on 14-4-13.
//  Copyright (c) 2014年 cxjwin. All rights reserved.
//

#import "WeiboUIStatus.h"
#import "NSMutableAttributedString+Weibo.h"

CGFloat kTextWidth = 250.0;

static CGSize sizeWithJpgData(NSData *data) {
	if ([data length] <= 0x58) {
		return CGSizeZero;
	}

	if ([data length] < 210) { // 肯定只有一个DQT字段
		short w1 = 0, w2 = 0;
		[data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
		[data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
		short w = (w1 << 8) + w2;
		short h1 = 0, h2 = 0;

		[data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
		[data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
		short h = (h1 << 8) + h2;
		return CGSizeMake(w, h);
	} else {
		short word = 0x0;
		[data getBytes:&word range:NSMakeRange(0x15, 0x1)];
		if (word == 0xdb) {
			[data getBytes:&word range:NSMakeRange(0x5a, 0x1)];
			if (word == 0xdb) { // 两个DQT字段
				short w1 = 0, w2 = 0;
				[data getBytes:&w1 range:NSMakeRange(0xa5, 0x1)];
				[data getBytes:&w2 range:NSMakeRange(0xa6, 0x1)];
				short w = (w1 << 8) + w2;

				short h1 = 0, h2 = 0;
				[data getBytes:&h1 range:NSMakeRange(0xa3, 0x1)];
				[data getBytes:&h2 range:NSMakeRange(0xa4, 0x1)];
				short h = (h1 << 8) + h2;
				return CGSizeMake(w, h);
			} else { // 一个DQT字段
				short w1 = 0, w2 = 0;
				[data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
				[data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
				short w = (w1 << 8) + w2;
				short h1 = 0, h2 = 0;

				[data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
				[data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
				short h = (h1 << 8) + h2;
				return CGSizeMake(w, h);
			}
		} else {
			return CGSizeZero;
		}
	}
}

static inline CGSize sizeWithGifData(NSData *data) {
	short w1 = 0, w2 = 0;
	[data getBytes:&w1 range:NSMakeRange(0, 1)];
	[data getBytes:&w2 range:NSMakeRange(1, 1)];
	short w = w1 + (w2 << 8);

	short h1 = 0, h2 = 0;
	[data getBytes:&h1 range:NSMakeRange(2, 1)];
	[data getBytes:&h2 range:NSMakeRange(3, 1)];
	short h = h1 + (h2 << 8);
	return CGSizeMake(w, h);
}

/*
 static inline CGSize sizeWithPngData(NSData *data)
 {
 int w1 = 0, w2 = 0, w3 = 0, w4 = 0;
 [data getBytes:&w1 range:NSMakeRange(0, 1)];
 [data getBytes:&w2 range:NSMakeRange(1, 1)];
 [data getBytes:&w3 range:NSMakeRange(2, 1)];
 [data getBytes:&w4 range:NSMakeRange(3, 1)];
 int w = (w1 << 24) + (w2 << 16) + (w3 << 8) + w4;
 int h1 = 0, h2 = 0, h3 = 0, h4 = 0;
 [data getBytes:&h1 range:NSMakeRange(4, 1)];
 [data getBytes:&h2 range:NSMakeRange(5, 1)];
 [data getBytes:&h3 range:NSMakeRange(6, 1)];
 [data getBytes:&h4 range:NSMakeRange(7, 1)];
 int h = (h1 << 24) + (h2 << 16) + (h3 << 8) + h4;

 return CGSizeMake(w, h);
 }
 */

@interface WeiboUIStatus ()

@property (nonatomic, strong, readwrite) id <WBGraphStatus> status;

@property (nonatomic, assign, readwrite) CGFloat contentHeight;

@property (nonatomic, copy, readwrite) NSMutableAttributedString *attributedText;

@property (nonatomic, assign, readwrite) CGSize textSize;

@property (nonatomic, copy, readwrite) NSMutableAttributedString *retweetedAttributedText;

@property (nonatomic, assign, readwrite) CGSize retweetedTextSize;

@property (nonatomic, assign, readwrite) DisplayImageType displayImageType;

@property (nonatomic, assign, readwrite) CGSize displayImageSize;

@property (nonatomic, assign, readwrite) ImagesManager *imagesManager;

@property (nonatomic, assign) NSDictionary *emojiDict;

@end

@implementation WeiboUIStatus

- (instancetype)initWithStatus:(id <WBGraphStatus> )status {
	self = [super init];
	if (self) {
		self.status = status;

		self.emojiDict = [NSMutableAttributedString weiboEmojiDictionary];

		CGFloat contentHeight = 0.0;

		if (status.text && [status.text length] > 0) {
		} else {
			NSAssert(NO, @"No Content in this status");
		}

		if ([[status retweeted_status] text] && [[[status retweeted_status] text] length] > 0) {
		}

		NSArray *imageURLs = [status pic_urls];
		NSUInteger count = [imageURLs count];
		if (!imageURLs || count == 0) {
			imageURLs = [[status retweeted_status] pic_urls];
			count = [imageURLs count];
		}

		if (!imageURLs || count) {
			self.displayImageType = DisplayNoImage;
			self.displayImageSize = CGSizeZero;
		} else if (count == 1) {
			self.displayImageType = DisplaySingleImage;
			self.displayImageSize = CGSizeMake(100, 100);
		} else if (count > 1) {
			self.displayImageType = DisplaySeveralImages;
			self.displayImageSize = CGSizeMake(64, 64);
			CGFloat imageWidth = 64.0;
			for (NSUInteger i = 0; i < count; ++i) {
			}
		} else {
			NSAssert(NO, @"No this kind");
		}
	}

	return self;
}

@end
