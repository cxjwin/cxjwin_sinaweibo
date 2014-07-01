//
//  BridgingView.h
//  SinaWeibo
//
//  Created by cxjwin on 6/13/14.
//  Copyright (c) 2014 cxjwin. All rights reserved.
//

#import <UIKit/UIKit.h>

// AvatarView
@class AvatarView;

@interface AvatarView : UIImageView

@property (copy, nonatomic) NSString *URLString;

@end

// StatusImageView
@class StatusImageView;

@interface StatusImageView : UIView

@property (copy, nonatomic) NSArray *URLStrings;

@property (assign, nonatomic) CGSize displaySize;

@end

// SeparateView
@class SeparateView;

@interface SeparateView : UIView

@end