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

@property (strong, nonatomic) NSTimer *drawTimer;
@property (assign, nonatomic) UITouchPhase touchPhase;
@property (assign, nonatomic) signed long touchIndex;

@end

@implementation CoreTextView 
{
    CTFrameRef textFrame;
    CFRange touchRange;
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
    CGFloat ascent = (kContentTextSize + 3) * 0.8;
    CGFloat descent = (kContentTextSize + 3) * 0.15;
    // CGFloat leading;
    runBounds.size.width = CTRunGetTypographicBounds(run, 
                                                     CFRangeMake(0, 0), 
                                                     NULL,
                                                     NULL,
                                                     NULL);        
    runBounds.size.height = ascent + descent; 
    CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringIndicesPtr(run)[0], NULL);
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
                CFRange range = CTRunGetStringRange(run);
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
                        NSRange _range = [value rangeValue];
                        CFRange linkRange = CFRangeMake(_range.location, _range.length);
                        
                        // 我们先绘制背景，不然文字会被背景覆盖
                        if (self.touchPhase == UITouchPhaseBegan) {// 点击开始
                            if (isTouchRange(self.touchIndex, linkRange, range)) {// 如果点击区域落在链接区域内
                                CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
                                CGContextFillRect(context, runBounds);
                            }
                        } else {// 点击结束
                            if (isTouchRange(self.touchIndex, linkRange, range)) {// 如果点击区域落在链接区域内
                                CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                                CGContextFillRect(context, runBounds);
                            }
                        }
                        
                        // 这里需要绘制下划线，记住CTRun是不会自动绘制下滑线的
                        // 即使你设置了这个属性也不行
                        // CTRun.h中已经做出了相应的说明
                        // 所以这里的下滑线我们需要自己手动绘制
                        CGContextSetStrokeColorWithColor(context, [UIColor purpleColor].CGColor);
                        CGContextSetLineWidth(context, 0.5);
                        CGContextMoveToPoint(context, runBounds.origin.x, runBounds.origin.y);
                        CGContextAddLineToPoint(context, runBounds.origin.x + runBounds.size.width, runBounds.origin.y);
                        CGContextStrokePath(context);
                    }
                }
                CTRunDraw(run, context, CFRangeMake(0, 0));
            }
        }
    }
}

#pragma mark -
#pragma mark - setters
- (void)setAttributedString:(NSMutableAttributedString *)attributedString {
    if (_attributedString != attributedString) {
        _attributedString = attributedString;
        
        [self updateFrameWithAttributedString];
        [self setNeedsDisplay];
    }
}

- (void)updateFrameWithAttributedString {
    if (textFrame) {
        CFRelease(textFrame), textFrame = NULL;
    }
    
    CTFramesetterRef framesetter = 
    CTFramesetterCreateWithAttributedString((__bridge CFMutableAttributedStringRef)_attributedString);
    CGMutablePathRef path = CGPathCreateMutable();
    CFRange fitCFRange = CFRangeMake(0,0);
    CGSize maxSize = CGSizeMake(_adjustWidth, CGFLOAT_MAX);
    CGSize sz = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), NULL, maxSize, &fitCFRange);
    _adjustSize = sz;
    CGRect rect = (CGRect){CGPointZero, sz};
    CGPathAddRect(path, NULL, rect);
    
    textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    CGPathRelease(path);
    CFRelease(framesetter);
}

Boolean CFRangesIntersect(CFRange range1, CFRange range2) {
    CFIndex max_location = MAX(range1.location, range2.location);
    CFIndex min_tail = MIN(range1.location + range1.length, range2.location + range2.length);
    if (min_tail - max_location > 0) {
        return true;
    } else {
        return false;
    }
}

Boolean isTouchRange(CFIndex index, CFRange touch_range, CFRange run_range) {
    if (touch_range.location < index && touch_range.location + touch_range.length >= index) {
        return CFRangesIntersect(touch_range, run_range);
    } else {
        return NO;
    }
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
        CGFloat ascent;
        CGFloat descent;
        CGFloat leading;
        CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        if ((origins[i].y - descent <= mirrorPoint.y) && 
            (origins[i].y + ascent >= mirrorPoint.y)) {
            tempIndex = CTLineGetStringIndexForPosition(line, mirrorPoint);
            self.touchPhase = touch.phase;
            if (tempIndex >= [self.attributedString length]) {
                CGFloat offset = CTLineGetOffsetForStringIndex(line, tempIndex, NULL);
                if (mirrorPoint.x > offset) {
                    tempIndex = kCFNotFound;
                }
            }
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
            CFRange range = CTRunGetStringRange(run);          
            // 获取CTRun的属性
            NSDictionary *attDic = (__bridge NSDictionary *)CTRunGetAttributes(run);
            NSNumber *num = [attDic objectForKey:kCustomGlyphTypeAttributeName];
            if (num) {
                int type = [num intValue];
                if (type == CustomGlyphURL) {// 如果是绘制链接
                    // 先取出链接的文字范围，后算计算点击区域的时候要用
                    NSValue *value = [attDic valueForKey:kCustomGlyphRangeAttributeName];
                    NSRange _range = [value rangeValue];
                    CFRange linkRange = CFRangeMake(_range.location, _range.length);
                    if (isTouchRange(self.touchIndex, linkRange, range)) {// 如果点击区域落在链接区域内
                        if ([_delegate respondsToSelector:@selector(touchedURLWithURLStr:)]) {
                            [_delegate touchedURLWithURLStr:[self.attributedString.string substringWithRange:_range]];
                        }
                        return;
                    }
                } else if (type == CustomGlyphAt) {
                    NSValue *value = [attDic valueForKey:kCustomGlyphRangeAttributeName];
                    NSRange _range = [value rangeValue];
                    CFRange linkRange = CFRangeMake(_range.location, _range.length);
                    if (isTouchRange(self.touchIndex, linkRange, range)) {// 如果点击区域落在链接区域内
                        if ([_delegate respondsToSelector:@selector(touchedURLWithAtStr:)]) {
                            [_delegate touchedURLWithAtStr:[self.attributedString.string substringWithRange:_range]];
                        }
                        return;
                    }
                } else if (type == CustomGlyphTopic) {
                    NSValue *value = [attDic valueForKey:kCustomGlyphRangeAttributeName];
                    NSRange _range = [value rangeValue];
                    CFRange linkRange = CFRangeMake(_range.location, _range.length);
                    if (isTouchRange(self.touchIndex, linkRange, range)) {// 如果点击区域落在链接区域内
                        if ([_delegate respondsToSelector:@selector(touchedURLWithTopicStr:)]) {
                            [_delegate touchedURLWithTopicStr:[self.attributedString.string substringWithRange:_range]];
                        }
                        return;
                    }
                }
            }
        }
    }
}

@end
