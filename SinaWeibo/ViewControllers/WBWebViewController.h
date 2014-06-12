//
//  WBWebViewController.h
//  SinaWeibo
//
//  Created by cxjwin on 13-9-25.
//  Copyright (c) 2013 cxjwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WBWebViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (copy, nonatomic) NSString *urlStr;

@end
