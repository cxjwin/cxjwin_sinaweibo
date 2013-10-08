//
//  CoreTextView.h
//  TEST_ATTR_002
//
//  Created by cxjwin on 13-7-29.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "CTSingleton.h"

#define kGifMaxFrames 50

@protocol CoreTextViewDelegate <NSObject>
@optional
- (void)touchedURLWithURLStr:(NSString *)urlStr;
- (void)touchedURLWithAtStr:(NSString *)atStr;
- (void)touchedURLWithTopicStr:(NSString *)topicStr;
@end

@interface CoreTextView : UIView

@property (weak, nonatomic) id<CoreTextViewDelegate> delegate;
@property (copy, nonatomic) NSMutableAttributedString *attributedString;
@property (assign, nonatomic) CGFloat adjustWidth;
@property (readonly, nonatomic) CGSize adjustSize;

- (void)updateFrameWithAttributedString;

@end