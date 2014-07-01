//
//  NSMutableAttributedString+Weibo.h
//  CoreTextDemo
//
//  Created by 蔡 雪钧 on 14-4-15.
//  Copyright (c) 2014年 cxjwin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CTAttachmentChar "\uFFFC"
#define CTAttachmentCharacter @"\uFFFC"

extern NSString *const kCustomGlyphAttributeType;
extern NSString *const kCustomGlyphAttributeRange;
extern NSString *const kCustomGlyphAttributeImageName;
extern NSString *const kCustomGlyphAttributeInfo;

typedef enum CustomGlyphAttributeType {
    CustomGlyphAttributeURL = 0,	// URL
    CustomGlyphAttributeAt,			// @
    CustomGlyphAttributeTopic,		// ##
    CustomGlyphAttributeImage,		// image
    CustomGlyphAttributeInfoImage,	// 预留，给带相应信息的图片（如点击图片获取相关属性）
} CustomGlyphAttributeType;

@interface CustomGlyphMetrics : NSObject

@property (nonatomic, assign) CGFloat ascent;

@property (nonatomic, assign) CGFloat descent;

@property (nonatomic, assign) CGFloat width;

- (instancetype)initWithAscent:(CGFloat)ascent descent:(CGFloat)descent width:(CGFloat)width;

@end

@interface NSAttributedString (Weibo)

- (CGSize)adjustSizeWithMaxWidth:(CGFloat)width;

@end

@interface NSMutableAttributedString (Weibo)

+ (NSDictionary *)weiboEmojiDictionary;

+ (NSMutableAttributedString *)weiboAttributedStringWithString:(NSString *)string;

@end
