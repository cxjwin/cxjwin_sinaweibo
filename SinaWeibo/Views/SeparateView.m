//
//  SeparateView.m
//  SinaWeibo
//
//  Created by cxjwin on 13-9-17.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import "SeparateView.h"

@implementation SeparateView {
	CGFloat lineWidth;
	UIView *leftLine;
	UIView *rightLine;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self initCommon];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initCommon];
    }
    return self;
}

- (void)initCommon {
	self.backgroundColor = [UIColor clearColor];
	self.textAlignment = NSTextAlignmentCenter;
	self.text = @"原文";
	
	lineWidth = 1.0 / [UIScreen mainScreen].scale;
	
	leftLine = [[UIView alloc] initWithFrame:CGRectZero];
	rightLine = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	leftLine.frame = CGRectMake(5, CGRectGetHeight(self.bounds) * 0.5, CGRectGetWidth(self.bounds) - 10, lineWidth);
	rightLine.frame =
	CGRectMake(CGRectGetWidth(self.bounds) + 5, CGRectGetHeight(self.bounds) * 0.5, CGRectGetWidth(self.bounds) - 10, lineWidth);
}

@end
