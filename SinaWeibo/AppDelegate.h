//
//  AppDelegate.h
//  SinaWeibo
//
//  Created by cxjwin on 13-8-19.
//  Copyright (c) 2013 cxjwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> 

@property (strong, nonatomic) UIWindow *window;

+ (instancetype)sharedDelegate;

@end
