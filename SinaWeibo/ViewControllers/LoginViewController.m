//
//  LoginViewController.m
//  SinaWeibo
//
//  Created by cxjwin on 13-8-19.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LoginViewController.h"
#import "SinaWeiboManager.h"
#import "WBTabBarController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}

	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kSinaWeiboDidLogInNotification object:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sinaWeiboDidLogIn) name:kSinaWeiboDidLogInNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[[SinaWeiboManager defaultManager] loginIn];
}

- (void)sinaWeiboDidLogIn {
	dispatch_async(dispatch_get_main_queue(), ^{
	    [self performSegueWithIdentifier:@"TabBarControllerSegue" sender:nil];
	});
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
