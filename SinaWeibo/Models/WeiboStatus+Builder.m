//
//  WeiboStatus+Builder.m
//  SinaWeibo
//
//  Created by cxjwin on 13-8-26.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import <objc/runtime.h>
#import "WeiboStatus+Builder.h"
#import "WeiboUser+Builder.h"
#import "NSMutableAttributedString+Weibo.h"
#import "CoreTextView.h"

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

static CGSize sizeWithGifData(NSData *data) {
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
static CGSize sizeWithPngData(NSData *data)
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

@implementation WeiboStatus (Builder)
static const char *attributed_text_key = "attributed_text_key";
- (void)setAttributedText:(NSMutableAttributedString *)attributedText {
	objc_setAssociatedObject(self, attributed_text_key, attributedText, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSMutableAttributedString *)attributedText {
	return objc_getAssociatedObject(self, attributed_text_key);
}

static const char *content_text_size_key = "content_text_size_key";
- (void)setContentTextSize:(NSValue *)contentTextSize {
	objc_setAssociatedObject(self, content_text_size_key, contentTextSize, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSValue *)contentTextSize {
	return objc_getAssociatedObject(self, content_text_size_key);
}

static const char *preview_image_size_key = "preview_image_size_key";
- (void)setPreviewImageSize:(NSValue *)previewImageSize {
	objc_setAssociatedObject(self, preview_image_size_key, previewImageSize, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSValue *)previewImageSize {
	NSValue *value = objc_getAssociatedObject(self, preview_image_size_key);
	if (!value) {
		value = [NSValue valueWithCGSize:CGSizeZero];
	}
	return value;
}

- (void)fillInDetailsWithJSONObject:(NSDictionary *)info {
	self.createdAt = [info objectForKey:@"created_at"];
	self.statusId = [info objectForKey:@"id"];
	self.statusIdstr = [info objectForKey:@"idstr"];
	self.mid = [info objectForKey:@"mid"];
	self.text = [info objectForKey:@"text"];
	if ([self.text length] > 0) {
		NSMutableAttributedString *attributedText = [NSMutableAttributedString weiboAttributedStringWithString:self.text];
		self.attributedText = attributedText;
		self.contentTextSize = [NSValue valueWithCGSize:[attributedText adjustSizeWithMaxWidth:kContentTextWidth]];
	}

	NSString *source = [info objectForKey:@"source"];
	if ([source length] > 0) {
		NSString *tempStr = [[source componentsSeparatedByString:@">"] objectAtIndex:1];
		self.source = [tempStr substringWithRange:NSMakeRange(0, [tempStr length] - 3)];
	}

	self.favorited = [info objectForKey:@"favorited"];
	self.truncated = [info objectForKey:@"truncated"];
	self.repostsCount = [info objectForKey:@"reposts_count"];
	self.commentsCount = [info objectForKey:@"comments_count"];
	self.attitudesCount = [info objectForKey:@"attitudes_count"];
	self.visible = [info objectForKey:@"visible"];
	self.geo = [info objectForKey:@"geo"];

	self.thumbnailPic = [info objectForKey:@"thumbnail_pic"];
	self.bmiddlePic = [info objectForKey:@"bmiddle_pic"];
	self.originalPic = [info objectForKey:@"original_pic"];
	self.picUrls = [info objectForKey:@"pic_urls"];

	NSDictionary *userInfo = [info objectForKey:@"user"];
	if (userInfo) {
		self.user = [[WeiboUser alloc] init];
		[self.user fillInDetailsWithJSONObject:userInfo];
	}

	NSDictionary *retweetedStatusInfo = [info objectForKey:@"retweeted_status"];
	if (retweetedStatusInfo) {
		self.retweetedStatus = [[WeiboStatus alloc] init];
		[self.retweetedStatus fillInDetailsWithJSONObject:retweetedStatusInfo];
	}
}

+ (NSMutableArray *)statusesFromJSONData:(NSData *)data error:(NSError **)error {
	NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:error];
	if (json == nil) {
		return nil;
	}

	NSMutableArray *array = [NSMutableArray array];
	NSArray *statusesInfos = [json objectForKey:@"statuses"];
	for (NSDictionary *info in statusesInfos) {
		WeiboStatus *status = [[WeiboStatus alloc] init];
		[status fillInDetailsWithJSONObject:info];
		[array addObject:status];
	}

	return array;
}

+ (NSMutableArray *)statusesWithPreviewImageSizeFromJSONData:(NSData *)data error:(NSError **)error {
	NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:error];
	if (json == nil) {
		return nil;
	}

	NSMutableArray *array = [NSMutableArray array];
	NSArray *statusesInfos = [json objectForKey:@"statuses"];
	for (NSDictionary *info in statusesInfos) {
		WeiboStatus *status = [[WeiboStatus alloc] init];
		[status fillInDetailsWithJSONObject:info];
		[array addObject:status];
	}

	NSURLSessionConfiguration *ephemeralConfigObject = [NSURLSessionConfiguration ephemeralSessionConfiguration];
	ephemeralConfigObject.timeoutIntervalForResource = 10;
	NSOperationQueue *delegateQueue = [[NSOperationQueue alloc] init];
	NSURLSession *ephemeralSession = [NSURLSession sessionWithConfiguration:ephemeralConfigObject delegate:nil delegateQueue:delegateQueue];
	for (WeiboStatus *status in array) {
		id result = [status pictureURLInStatus];
		if (result) {
			if ([result isKindOfClass:[NSMutableArray class]]) {
				CGSize size = CGSizeMake(64 * 3, 64 * 3);
				status.previewImageSize = [NSValue valueWithCGSize:size];
			} else {
				NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:(NSURL *)result];
				NSString *pathExtension = [[[request URL] absoluteString] pathExtension];
				if ([[pathExtension lowercaseString] isEqualToString:@"gif"]) { // gif
					[request setValue:@"bytes=6-9" forHTTPHeaderField:@"Range"];
					__block __weak WeiboStatus *weak_status = status;
					[[ephemeralSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
					    if ([data length] > 0) {
					        CGSize size = sizeWithGifData(data);
					        weak_status.previewImageSize = [NSValue valueWithCGSize:size];
						} else {
					        // error
						}
					}] resume];
				} else { // jpg
					[request setValue:@"bytes=0-209" forHTTPHeaderField:@"Range"];
					__block __weak WeiboStatus *weak_status = status;
					[[ephemeralSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
					    if ([data length] > 0) {
					        CGSize size = sizeWithJpgData(data);
					        weak_status.previewImageSize = [NSValue valueWithCGSize:size];
						} else {
					        // error
						}
					}] resume];
				}
			}
		}
	}

	[delegateQueue waitUntilAllOperationsAreFinished];

	return array;
}

- (id)pictureURLInStatus {
	WeiboStatus *picStatus = (self.retweetedStatus != nil ? self.retweetedStatus : self);
	NSUInteger picCount = [picStatus.picUrls count];
	// multiple pics
	if (picCount > 1) {
		NSMutableArray *picURLs = [NSMutableArray array];
		for (NSDictionary *dict in picStatus.picUrls) {
			NSURL *picURL = [NSURL URLWithString:[dict objectForKey:@"thumbnail_pic"]];
			[picURLs addObject:picURL];
		}

		return picURLs;
	} else if (picCount == 1) {
		NSURL *picURL = [NSURL URLWithString:[[picStatus.picUrls objectAtIndex:0] objectForKey:@"thumbnail_pic"]];
		return picURL;
	} else {
		NSURL *picURL = nil;
		if (picStatus.thumbnailPic) {
			picURL = [NSURL URLWithString:picStatus.thumbnailPic];
		} else if (picStatus.bmiddlePic) {
			picURL = [NSURL URLWithString:picStatus.bmiddlePic];
		} else if (picStatus.originalPic) {
			picURL = [NSURL URLWithString:picStatus.originalPic];
		}

		return picURL;
	}
}

@end
