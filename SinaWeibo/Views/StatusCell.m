//
//  StatusCell.m
//  SinaWeibo
//
//  Created by cxjwin on 13-9-16.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import "StatusCell.h"

@implementation StatusCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.statusView = [[StatusView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.statusView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame));
    self.statusView.frame = frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end