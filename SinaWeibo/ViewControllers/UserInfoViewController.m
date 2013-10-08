//
//  UserInfoViewController.m
//  SinaWeibo
//
//  Created by cxjwin on 13-9-25.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import <SDWebImage/SDWebImageManager.h>
#import "UserInfoViewController.h"
#import "SinaWeiboManager.h"

@interface UserInfoViewController ()

@end

@implementation UserInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    __weak UIImageView *imageView = (id)[self.view viewWithTag:101];
    
    SinaWeiboCommunicator *communicator = [[SinaWeiboManager defaultManager] communicator];
    NSURLCache *URLCache = communicator.defaultSession.configuration.URLCache;
    
    NSURL *avatarUrl = nil;
    if (self.user.profileImageUrl) {
        if (self.user.avatarLarge) {
            avatarUrl = [NSURL URLWithString:self.user.avatarLarge];
        } else {
            avatarUrl = [NSURL URLWithString:self.user.profileImageUrl];
        }
    }
    
    if (avatarUrl) {
        NSURLRequest *request = [NSURLRequest requestWithURL:avatarUrl];
        NSCachedURLResponse *response = [URLCache cachedResponseForRequest:request];
        if (response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = [UIImage imageWithData:response.data];
            });
        } else {
            [communicator downloadImageWithURL:avatarUrl 
                     downloadCompletionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                         if (error == nil && [data length] > 0) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 imageView.image = [UIImage imageWithData:data];
                             });
                         }
                     }];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"%s", __func__);
}

@end
