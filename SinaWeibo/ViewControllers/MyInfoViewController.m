//
//  MyInfoViewController.m
//  SinaWeibo
//
//  Created by cxjwin on 13-9-27.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import "MyInfoViewController.h"
#import "SinaWeiboManager.h"
#import "WeiboUser+Builder.h"
#import "WeiboStatus+Builder.h"
#import "StatusCell.h"

#define kAvatarViewTag 201
const NSUInteger kNumberOfSections = 5;

@interface MyInfoViewController ()

@property (strong, nonatomic) WeiboStatus *latestStatus;

@end

@implementation MyInfoViewController
{
    __weak WeiboUser *currentUer;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kWeiboUserInfoDidUpdateNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundTile"]];
    
    currentUer = [[SinaWeiboManager defaultManager] user];
    self.latestStatus = [[WeiboStatus alloc] init];
    
    [self createTableHeaderView];
    [self createTableFooterView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserView) name:kWeiboUserInfoDidUpdateNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (currentUer.userId) {
        [self refreshUserView];
    } else {
        [[SinaWeiboManager defaultManager] getCurrentUserInfo];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createTableHeaderView
{
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 80);
    UIView *view = [[UIView alloc] initWithFrame:frame];
    
    CGRect imageViewFrame = CGRectMake(0, 0, 56, 56);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
    imageView.center = CGPointMake(40, 40);
    imageView.tag = kAvatarViewTag;
    [view addSubview:imageView];
    
    self.tableView.tableHeaderView = view;
}

- (void)createTableFooterView
{
    
}

- (void)refreshUserView
{
    __weak UIImageView *imageView = (id)[self.tableView.tableHeaderView viewWithTag:kAvatarViewTag];
    
    SinaWeiboCommunicator *communicator = [[SinaWeiboManager defaultManager] communicator];
    NSURLCache *URLCache = communicator.defaultSession.configuration.URLCache;
    
    NSURL *avatarUrl = nil;
    if (currentUer.profileImageUrl) {
        if (currentUer.avatarLarge) {
            avatarUrl = [NSURL URLWithString:currentUer.avatarLarge];
        } else {
            avatarUrl = [NSURL URLWithString:currentUer.profileImageUrl];
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
    
    [self.latestStatus fillInDetailsWithJSONObject:currentUer.status];
    [self.tableView reloadData];
}

#pragma mark - 
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;//kNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentifier_1 = @"StatusCell";
    UITableViewCell *cell = nil;
    switch (indexPath.section) {
        case 0:
        {
            StatusCell *_cell = (StatusCell *)[tableView dequeueReusableCellWithIdentifier:indentifier_1];
            _cell.statusView.status = self.latestStatus;
            cell = _cell;
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (BOOL)hasPictureInStatus:(WeiboStatus *)status {
    WeiboStatus *picStatus = (status.retweetedStatus != nil ? status.retweetedStatus : status);
    if ([picStatus.picUrls count] > 0 || picStatus.thumbnailPic || picStatus.bmiddlePic || picStatus.originalPic) {
        return YES;
    } else {
        return NO;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    switch (indexPath.section) {
        case 0:
        {
            // height for avatar & name & from ...
            height = 48;
            
            // height for status text
            height = 3 + height + [self.latestStatus.contentTextSize CGSizeValue].height + 3;// status text
            if (self.latestStatus.retweetedStatus) {
                // height for separtion view
                height = 2 + height + 16 + 2;
                // height for retweeted status text
                height = 3 + height + [self.latestStatus.retweetedStatus.contentTextSize CGSizeValue].height + 3;
            }
            
            if ([self hasPictureInStatus:self.latestStatus]) {
                // height for pic view
                height = 3 + height + 64 + 3;
            }
            
            // height for tool bar
            height = 5 + height + 16 + 10;
        }
            break;
            
        default:
            break;
    }
    
    return height;
}

@end
