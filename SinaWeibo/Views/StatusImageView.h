//
//  StatusImageView.h
//  SinaWeibo
//
//  Created by cxjwin on 6/13/14.
//  Copyright (c) 2014 cxjwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatusImageView : UIImageView

@property (nonatomic, copy) NSArray *URLStrings;

- (CGSize)displaySize;

@end
