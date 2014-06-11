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
	UILabel *label;
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
	lineWidth = 1.0 / [UIScreen mainScreen].scale;
	
	// left line
	leftLine = [[UIView alloc] initWithFrame:CGRectZero];
	leftLine.backgroundColor = [UIColor grayColor];
	[self addSubview:leftLine];
	
	// right line
	rightLine = [[UIView alloc] initWithFrame:CGRectZero];
	rightLine.backgroundColor = [UIColor grayColor];
	[self addSubview:rightLine];
	
	// label
	label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.backgroundColor = [UIColor clearColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.font = [UIFont systemFontOfSize:12];
	label.textColor = [UIColor purpleColor];
	label.text = @"原文";
	[self addSubview:label];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGSize labelSize = [label sizeThatFits:CGSizeMake(60, label.font.lineHeight)];
	CGRect labelFrame =
	CGRectMake((CGRectGetWidth(self.bounds) - labelSize.width) * 0.5, (CGRectGetHeight(self.bounds) - labelSize.height) * 0.5, labelSize.width, labelSize.height);
	label.frame = CGRectIntegral(labelFrame);
	
	leftLine.frame = CGRectMake(15, CGRectGetHeight(self.bounds) * 0.5, CGRectGetWidth(self.bounds) * 0.5 - 30, lineWidth);
	rightLine.frame =
	CGRectMake(CGRectGetWidth(self.bounds) * 0.5 + 15, CGRectGetHeight(self.bounds) * 0.5, CGRectGetWidth(self.bounds) * 0.5 - 30, lineWidth);
}

@end
