//
//  CTSingleton.m
//  CoreTextDemo
//
//  Created by cxjwin on 13-8-28.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import "CTSingleton.h"
#import <ImageIO/ImageIO.h>

CGFloat kContentTextWidth = 280;  
NSString *const kCustomGlyphTypeAttributeName = @"kCustomGlyphTypeAttributeName";
NSString *const kCustomGlyphRangeAttributeName = @"kCustomGlyphRangeAttributeName";
NSString *const kCustomGlyphImageAttributeName = @"kCustomGlyphImageAttributeName";
NSString *const kCustomGlyphInfoAttribute = @"kCustomGlyphInfoAttribute";

@implementation GifObject

@end

@implementation CTSingleton 

static CTSingleton *singleton = nil;
+ (id)sharedInstance 
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[CTSingleton alloc] init];
    });
    return singleton;
}

- (id)init 
{
    self = [super init];
    if (self) {
        NSString *emojiFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"emotionImage.plist"];
        self.emojiDict = [[NSDictionary alloc] initWithContentsOfFile:emojiFilePath];
        self.gifCache = [[NSCache alloc] init];
        [self.gifCache setCountLimit:-1];
    }
    return self;
}

// 将普通文字转化成绘文字
- (NSMutableAttributedString *)transformText:(NSString *)text {  
    NSMutableAttributedString *newStr = [[NSMutableAttributedString alloc] init];
    
    // 匹配emoji
    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    NSRegularExpression *exp_emoji = 
    [[NSRegularExpression alloc] initWithPattern:regex_emoji
                                         options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                           error:nil];
    NSArray *emojis = [exp_emoji matchesInString:text 
                                         options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                           range:NSMakeRange(0, [text length])];
    NSUInteger location = 0;
    for (NSTextCheckingResult *result in emojis) {
        NSRange range = result.range;
        NSString *subStr = [text substringWithRange:NSMakeRange(location, range.location - location)];
        NSMutableAttributedString *attSubStr = [[NSMutableAttributedString alloc] initWithString:subStr];
        [newStr appendAttributedString:attSubStr];
        
        location = range.location + range.length;
        
        NSString *emojiKey = [text substringWithRange:range];
        NSString *imageName = [self.emojiDict objectForKey:emojiKey];
        if (imageName) {
            UIImage *image = [UIImage imageNamed:imageName];
            NSTextAttachment *attachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
            attachment.image = image;
            attachment.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
            NSAttributedString *attachmentStr = [NSAttributedString attributedStringWithAttachment:attachment];
            [newStr appendAttributedString:attachmentStr];
        } else {
            NSString *rSubStr = [text substringWithRange:range];
            NSAttributedString *originalStr = [[NSAttributedString alloc] initWithString:rSubStr];
            [newStr appendAttributedString:originalStr];
        }
    }
    
    if (location < [text length]) {
        NSRange range = NSMakeRange(location, [text length] - location);
        NSString *subStr = [text substringWithRange:range];
        NSAttributedString *attSubStr = [[NSAttributedString alloc] initWithString:subStr];
        [newStr appendAttributedString:attSubStr];
    }
    
    // 匹配短链接
    NSString *__newStr = [newStr string];
    NSString *regex_http = @"http://t.cn/[a-zA-Z0-9]+";// 短链接的算法是固定的，格式比较一直，所以比较好匹配
    NSRegularExpression *exp_http = 
    [[NSRegularExpression alloc] initWithPattern:regex_http
                                         options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                           error:nil];
    NSArray *https = [exp_http matchesInString:__newStr
                                       options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators 
                                         range:NSMakeRange(0, [__newStr length])];
    
    for (NSTextCheckingResult *result in https) {
        NSRange _range = [result range];
        // 设置自定义属性，绘制的时候需要用到
        [newStr addAttribute:kCustomGlyphTypeAttributeName 
                       value:[NSNumber numberWithInt:CustomGlyphURL] 
                       range:_range];
        [newStr addAttribute:kCustomGlyphRangeAttributeName
                       value:[NSValue valueWithRange:_range] 
                       range:_range];
        [newStr addAttribute:NSForegroundColorAttributeName 
                       value:[UIColor blueColor] 
                       range:_range];
    }
    
    // 匹配@
    NSString *regex_at = @"@[\\u4e00-\\u9fa5\\w\\-]+";
    NSRegularExpression *exp_at = 
    [[NSRegularExpression alloc] initWithPattern:regex_at
                                         options:(NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators)
                                           error:nil];
    NSArray *ats = 
    [exp_at matchesInString:__newStr
                    options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators 
                      range:NSMakeRange(0, [__newStr length])];
    for (NSTextCheckingResult *result in ats) {
        NSRange _range = [result range];
        // 设置自定义属性，绘制的时候需要用到
        [newStr addAttribute:kCustomGlyphTypeAttributeName 
                       value:[NSNumber numberWithInt:CustomGlyphAt] 
                       range:_range];
        [newStr addAttribute:kCustomGlyphRangeAttributeName
                       value:[NSValue valueWithRange:_range] 
                       range:_range];
        [newStr addAttribute:NSForegroundColorAttributeName 
                       value:[UIColor purpleColor] 
                       range:_range];
    }
    
    // 匹配＃＃
    NSString *regex_topic = @"#([^\\#|.]+)#";
    NSRegularExpression *exp_topic = 
    [[NSRegularExpression alloc] initWithPattern:regex_topic
                                         options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                           error:nil];
    NSArray *topics = 
    [exp_topic matchesInString:__newStr
                       options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators 
                         range:NSMakeRange(0, [__newStr length])];
    for (NSTextCheckingResult *result in topics) {
        NSRange _range = [result range];
        // 设置自定义属性，绘制的时候需要用到
        [newStr addAttribute:kCustomGlyphTypeAttributeName 
                       value:[NSNumber numberWithInt:CustomGlyphTopic] 
                       range:_range];
        [newStr addAttribute:kCustomGlyphRangeAttributeName
                       value:[NSValue valueWithRange:_range] 
                       range:_range];
        [newStr addAttribute:NSForegroundColorAttributeName 
                       value:[UIColor purpleColor]
                       range:_range];
    }
    
    NSRange allTextRange = NSMakeRange(0, [newStr.string length]);
    [newStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:kContentTextSize] range:allTextRange];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineSpacing = kLineSpacing;
    [newStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:allTextRange];
    
    return newStr;
}

- (NSValue *)sizeValueWithAttributedText:(NSMutableAttributedString *)attributedText {
    CTFramesetterRef framesetter = 
    CTFramesetterCreateWithAttributedString((__bridge CFMutableAttributedStringRef)attributedText);
    CFRange fitCFRange = CFRangeMake(0, 0);
    CGSize maxSize = CGSizeMake(kContentTextWidth, CGFLOAT_MAX);
    CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, maxSize, &fitCFRange);
    CFRelease(framesetter);
    return [NSValue valueWithCGSize:size];
}

// Returns the image object rendered by NSLayoutManager at imageBounds inside textContainer.  It should return an image appropriate for the target rendering context derived by arguments to this method.  The NSTextAttachment implementation returns -image when non-nil.  If -image==nil, it returns an image based on -contents and -fileType properties.
- (UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex  NS_AVAILABLE_IOS(7_0)
{
    return nil;
}


// Returns the layout bounds to the layout manager.  The bounds origin is interpreted to match position inside lineFrag.  The NSTextAttachment implementation returns -bounds if not CGRectZero; otherwise, it derives the bounds value from -[image size].  Conforming objects can implement more sophisticated logic for negotiating the frame size based on the available container space and proposed line fragment rect.
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex NS_AVAILABLE_IOS(7_0)
{
    return CGRectZero;
}

@end
