//
//  SeparateView.m
//  SinaWeibo
//
//  Created by cxjwin on 13-9-17.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import "SeparateView.h"

@implementation SeparateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextSetLineWidth(context, 0.5);
    
    CGFloat lineY = CGRectGetHeight(rect) * 0.5 + 0.25;
    CGContextMoveToPoint(context, 0, lineY);
    CGContextAddLineToPoint(context, CGRectGetWidth(rect) * 0.5 - 15, lineY);

    CGContextMoveToPoint(context, CGRectGetWidth(rect) * 0.5 + 15, lineY);
    CGContextAddLineToPoint(context, CGRectGetWidth(rect), lineY);
    
    CGContextStrokePath(context);
    
    NSString *string = @"原文";
    [string drawAtPoint:CGPointMake(CGRectGetWidth(rect) * 0.5 - 12, 0)
         withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12],
                          NSForegroundColorAttributeName : [UIColor grayColor]}];
}

@end
