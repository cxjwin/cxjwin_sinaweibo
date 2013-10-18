//
//  CoreTextView.m
//  TEST_ATTR_002
//
//  Created by cxjwin on 13-7-29.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import "CoreTextView.h"
#import <ImageIO/ImageIO.h>

@interface CoreTextView ()

@property (assign, nonatomic) UITouchPhase touchPhase;
@property (assign, nonatomic) signed long touchIndex;

@end

@implementation CoreTextView 
{
    CTFrameRef textFrame;
    CFRange touchRange;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib 
{
    [self commonInit];
}

- (void)commonInit 
{    
    self.touchIndex = kCFNotFound;
    self.adjustWidth = kContentTextWidth;
}

- (void)dealloc 
{
    if (textFrame) {
        CFRelease(textFrame), textFrame = NULL;
    }
}

NSRange NSRangeFromCFRange(CFRange range)
{
	return NSMakeRange((NSUInteger)range.location, (NSUInteger)range.length);
}

BOOL CTLineContainsCharactersFromStringRange(CTLineRef line, NSRange range)
{
	NSRange lineRange = NSRangeFromCFRange(CTLineGetStringRange(line));
	NSRange intersectedRange = NSIntersectionRange(lineRange, range);
	return (intersectedRange.length > 0);
}

BOOL CTRunContainsCharactersFromStringRange(CTRunRef run, NSRange range)
{
	NSRange runRange = NSRangeFromCFRange(CTRunGetStringRange(run));
	NSRange intersectedRange = NSIntersectionRange(runRange, range);
	return (intersectedRange.length > 0);
}

// Don't use this method for origins. Origins always depend on the height of the rect.
CGPoint CGPointFlipped(CGPoint point, CGRect bounds) 
{
	return CGPointMake(point.x, CGRectGetMaxY(bounds) - point.y);
}

CGRect CGRectFlipped(CGRect rect, CGRect bounds) 
{
	return CGRectMake(CGRectGetMinX(rect),
                      CGRectGetMaxY(bounds) - CGRectGetMaxY(rect),
                      CGRectGetWidth(rect),
                      CGRectGetHeight(rect));
}

CGRect getRunBounds(CTRunRef run, CTLineRef line, CGPoint lineOrigin) 
{
    CGRect runBounds;
    CGFloat ascent = 0;
    CGFloat descent = 0;
    
    CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
    runBounds.size.width = CTRunGetTypographicBounds(run, 
                                                     CFRangeMake(0, 0), 
                                                     NULL,
                                                     NULL,
                                                     NULL);        
    runBounds.size.height = ascent + descent; 
    CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
    runBounds.origin.x = lineOrigin.x + xOffset;
    runBounds.origin.y = lineOrigin.y - descent;
    return runBounds;
}

- (void)drawRect:(CGRect)rect 
{
    if (textFrame) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, rect.size.height);
        CGContextConcatCTM(context, flipVertical);
        CGContextSetTextDrawingMode(context, kCGTextFill);
        
        // 获取CTFrame中的CTLine
        CFArrayRef lines = CTFrameGetLines(textFrame);
        CGPoint origins[CFArrayGetCount(lines)];
        CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
        
        for (int i = 0; i < CFArrayGetCount(lines); i++) {
            // 获取CTLine中的CTRun
            CTLineRef line = CFArrayGetValueAtIndex(lines, i);
            CFArrayRef runs = CTLineGetGlyphRuns(line);

            for (int j = 0; j < CFArrayGetCount(runs); j++) {
                CTRunRef run = CFArrayGetValueAtIndex(runs, j);
                CGContextSetTextPosition(context, origins[i].x, origins[i].y);                
                // 获取CTRun的属性
                NSDictionary *attDic = (__bridge NSDictionary *)CTRunGetAttributes(run);
                NSNumber *num = [attDic objectForKey:kCustomGlyphTypeAttributeName];
                if (num) {
                    int type = [num intValue];
                    if (type == CustomGlyphURL || type == CustomGlyphAt || type == CustomGlyphTopic) {// 如果是绘制链接,@,##
                        // 先取出链接的文字范围，后算计算点击区域的时候要用
                        CGRect runBounds = getRunBounds(run, line, origins[i]);
                        NSValue *value = [attDic valueForKey:kCustomGlyphRangeAttributeName];
                        NSRange linkRange = [value rangeValue];
                        
                        if (NSLocationInRange(self.touchIndex, linkRange)) {
                            if (CTRunContainsCharactersFromStringRange(run, linkRange)) {
                                if (self.touchPhase == UITouchPhaseBegan) {                               
                                    CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
                                } else {
                                    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                                }
                                CGContextFillRect(context, runBounds);
                            } 
                        }
                        
                    }
                }
                //CTRunDraw(run, context, CFRangeMake(0, 0));
            }
        }
        
        CTFrameDraw(textFrame, context);
    }
}

#pragma mark -
#pragma mark - setters
- (void)setAttributedString:(NSMutableAttributedString *)attributedString 
{
    if (_attributedString != attributedString) {
        _attributedString = attributedString;
        
        [self updateFrameWithAttributedString];
        [self setNeedsDisplay];
    }
}

- (void)updateFrameWithAttributedString 
{
    if (textFrame) {
        CFRelease(textFrame), textFrame = NULL;
    }
    
    CTFramesetterRef framesetter = 
    CTFramesetterCreateWithAttributedString((__bridge CFMutableAttributedStringRef)_attributedString);
    CGMutablePathRef path = CGPathCreateMutable();
    CFRange fitCFRange = CFRangeMake(0, 0);
    CGSize maxSize = CGSizeMake(self.adjustWidth, CGFLOAT_MAX);
    CGSize sz = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), NULL, maxSize, &fitCFRange);
    _adjustSize = sz;
    CGRect rect = (CGRect){CGPointZero, sz};
    CGPathAddRect(path, NULL, rect);
    
    textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    CGPathRelease(path);
    CFRelease(framesetter);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGPoint mirrorPoint = CGPointFlipped(point, self.bounds);
    
    CFArrayRef lines = CTFrameGetLines(textFrame);
    CGPoint origins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
    
    // 获取点击的文字位置
    CFIndex tempIndex = kCFNotFound;
    for (int i = 0; i < CFArrayGetCount(lines); i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGFloat ascent = 0;
        CGFloat descent = 0;
        
        double lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
        double whitespaceWidth = CTLineGetTrailingWhitespaceWidth(line);
        CGRect lineRect = CGRectMake(origins[i].x, origins[i].y - descent, lineWidth - whitespaceWidth, ascent + descent);
        if (CGRectContainsPoint(lineRect, mirrorPoint)) {
            tempIndex = CTLineGetStringIndexForPosition(line, mirrorPoint);
            self.touchPhase = touch.phase;
        }
    }
    self.touchIndex = tempIndex;
    if (self.touchIndex != kCFNotFound) {
        [self catchTouchedString];
        [self setNeedsDisplay];
    }
    
    __weak typeof(self) weak_self = self;
    double delayInSeconds = 0.25;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        weak_self.touchPhase = UITouchPhaseEnded;
        if (weak_self.touchIndex != kCFNotFound) {
            [weak_self setNeedsDisplay];
        }
    });
}

/*
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
    UITouch *touch = [touches anyObject];
    touchPhase = touch.phase;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    touchPhase = touch.phase;
    if (touchIndex != kCFNotFound) {
        [self setNeedsDisplay];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    touchPhase = touch.phase;
    if (touchIndex != kCFNotFound) {
        [self setNeedsDisplay];
    }
}
*/

- (void)catchTouchedString {
    if (textFrame == nil) {
        return;
    }
    // 获取CTFrame中的CTLine
    CFArrayRef lines = CTFrameGetLines(textFrame);
    CGPoint origins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
        
    for (int i = 0; i < CFArrayGetCount(lines); i++) {
        // 获取CTLine中的CTRun
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        for (int j = 0; j < CFArrayGetCount(runs); j++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            // 获取CTRun的属性
            NSDictionary *attDic = (__bridge NSDictionary *)CTRunGetAttributes(run);
            NSNumber *num = [attDic objectForKey:kCustomGlyphTypeAttributeName];
            if (num) {
                int type = [num intValue];
                if (type == CustomGlyphURL) {// 如果是绘制链接
                    // 先取出链接的文字范围，后算计算点击区域的时候要用
                    NSValue *value = [attDic valueForKey:kCustomGlyphRangeAttributeName];
                    NSRange linkRange = [value rangeValue];
                    if (NSLocationInRange(self.touchIndex, linkRange)) {
                        if (CTRunContainsCharactersFromStringRange(run, linkRange)) {
                            if ([_delegate respondsToSelector:@selector(touchedURLWithURLStr:)]) {
                                [_delegate touchedURLWithURLStr:[self.attributedString.string substringWithRange:linkRange]];
                            }
                            return;
                        }
                    }
                } else if (type == CustomGlyphAt) {
                    NSValue *value = [attDic valueForKey:kCustomGlyphRangeAttributeName];
                    NSRange linkRange = [value rangeValue];
                    if (NSLocationInRange(self.touchIndex, linkRange)) {
                        if (CTRunContainsCharactersFromStringRange(run, linkRange)) {
                            if ([_delegate respondsToSelector:@selector(touchedURLWithAtStr:)]) {
                                [_delegate touchedURLWithAtStr:[self.attributedString.string substringWithRange:linkRange]];
                            }
                            return;
                        }
                    }
                } else if (type == CustomGlyphTopic) {
                    NSValue *value = [attDic valueForKey:kCustomGlyphRangeAttributeName];
                    NSRange linkRange = [value rangeValue];
                    if (NSLocationInRange(self.touchIndex, linkRange)) {
                        if (CTRunContainsCharactersFromStringRange(run, linkRange)) {
                            if ([_delegate respondsToSelector:@selector(touchedURLWithTopicStr:)]) {
                                [_delegate touchedURLWithTopicStr:[self.attributedString.string substringWithRange:linkRange]];
                            }
                            return;
                        }
                    }
                }
            }
        }
    }
}

@end
