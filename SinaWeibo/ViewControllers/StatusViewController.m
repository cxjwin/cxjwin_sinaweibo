//
//  StatusViewController.m
//  SinaWeibo
//
//  Created by cxjwin on 13-8-19.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import "StatusViewController.h"
#import "SinaWeiboManager.h"
#import "DatabaseManager.h"
#import "SinaWeiboCommunicator.h"
#import "WeiboStatus+Builder.h"
#import "WeiboUser.h"
#import "StatusCell.h"
#import "UserInfoViewController.h"
#import "WBWebViewController.h"

@interface StatusViewController ()

@property (assign, atomic) int nextPage;
@property (retain, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSURL *item;

@end

@implementation StatusViewController {
    __weak SinaWeiboCommunicator *communicator;
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
    [self removeObservers];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundTile"]];
    
    [self addObservers];
    
    communicator = [[SinaWeiboManager defaultManager] communicator];
    self.nextPage = 1;
    self.dataArray = [NSMutableArray array];
    
    // sub views
    CGRect tableFooterViewFrame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 1);
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:tableFooterViewFrame];
    self.tableView.tableFooterView.backgroundColor = [UIColor whiteColor];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    // title view
    WeiboUser *user = [[SinaWeiboManager defaultManager] user];
    if (user.screenName) {
        self.title = user.screenName;
    } else {
        self.title = @"我";
    }
    
    // load data
    [self loadStatusesDataFromDB];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 
#pragma mark - load Statuses Data FromDB
- (void)loadStatusesDataFromDB {
    FMDatabase *database = [[DatabaseManager defaultManager] database];
    FMResultSet *resultSet = [database executeQuery:@"select * from statuses_data;"];
    self.statuses = [NSMutableArray array];
    while ([resultSet next]) {
        NSData *data = [resultSet dataForColumnIndex:0];
        NSError *error = nil;
        NSMutableArray *statuses = [WeiboStatus statusesFromJSONData:data error:&error];
        if (statuses) {
            [self.statuses addObjectsFromArray:statuses];
        } else {
            NSLog(@"error : %@", [error localizedDescription]);
        }
    }
    
    [self.tableView performSelector:@selector(reloadData) onThread:[NSThread mainThread] withObject:nil waitUntilDone:YES];
    [self loadStatusesData];
}

#pragma mark - 
#pragma mark - status communicator
- (void)loadStatusesData {
    __weak typeof(self) weak_self = self;
    DataCompletionHandler completionHandler =
    ^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weak_self.refreshControl.isRefreshing) {
                [weak_self.refreshControl endRefreshing];
            }
        });
        if (error) {
            WBLog(@"net error : %@", [error localizedDescription]);
        } else {
            NSError *_error = nil;
            NSMutableArray *statuses =
            [WeiboStatus statusesWithPreviewImageSizeFromJSONData:data error:&_error];
            //[WeiboStatus statusesFromJSONData:data error:&_error];
            if (statuses) {
                [weak_self.dataArray removeAllObjects];
                [weak_self.dataArray addObject:data];
                weak_self.nextPage = 2;
                weak_self.statuses = statuses;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weak_self.tableView reloadData];
                });
            } else {
                weak_self.nextPage = 1;
                WBLog(@"net error : %@", [_error localizedDescription]);
            }
        }
    };
    [communicator getWeiboStatusesWithPage:1 completionHandler:completionHandler];
}

- (void)loadNextPageStatusesData {
    if (self.nextPage < 2) {
        return;
    }
    __weak typeof(self) weak_self = self;
    DataCompletionHandler completionHandler = 
    ^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *_error = nil;
        NSMutableArray *statuses = [WeiboStatus statusesFromJSONData:data error:&_error];
        if (statuses) {
            [weak_self.dataArray addObject:data];
            
            weak_self.nextPage = weak_self.nextPage + 1;
            [weak_self.statuses addObjectsFromArray:statuses];
            [weak_self.tableView reloadData];
        } else {
            NSLog(@"error : %@", [_error localizedDescription]);
        }
    };
    [communicator getWeiboStatusesWithPage:self.nextPage completionHandler:completionHandler];
}

- (void)refreshControlValueChanged:(id)sender
{
    UIRefreshControl *control = sender;
    WBLog(@"%d", control.refreshing);
    if (control.refreshing) {
        [self loadStatusesData];
    }
}

#pragma mark - 
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.statuses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *indentifier = @"StatusCell";
    StatusCell *cell = (StatusCell *)[tableView dequeueReusableCellWithIdentifier:indentifier];
    
#ifdef DEBUG
    assert(indexPath.row < [self.statuses count]);
#endif
    WeiboStatus *status = [self.statuses objectAtIndex:indexPath.row];
    [cell.statusView setStatus:status];
    
    return cell;
}

#pragma mark - 
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
#ifdef DEBUG
    assert(indexPath.row < [self.statuses count]);
#endif
    // height for avatar & name & from ...
    CGFloat height = 48;
    
    // height for status text
    WeiboStatus *status = [self.statuses objectAtIndex:indexPath.row];
    height = 3 + height + [status.contentTextSize CGSizeValue].height + 3;// status text
    if (status.retweetedStatus) {
        // height for separtion view
        height = 2 + height + 16 + 2;
        // height for retweeted status text
        height = 3 + height + [status.retweetedStatus.contentTextSize CGSizeValue].height + 3;
    }
    
    id result = [status pictureURLInStatus];
    if (result) {
//        if ([result isKindOfClass:[NSMutableArray class]]) {
//            NSMutableArray *picURLs = result;
//            NSUInteger count = ceil([picURLs count] / 3.0f);
//            height = 3 + height + 64 * count + 3;
//        } else {
//            NSURL *picURL = result;
//            SDWebImageManager *manager = [SDWebImageManager sharedManager];
//            UIImage *image = [manager.imageCache imageFromMemoryCacheForKey:[picURL absoluteString]];
//            if (image) {
//                height = 3 + height + image.size.height + 3;
//            } else {
//                height = 3 + height + 64 + 3;
//            }
//        }
        
        height = 3 + height + [status.previewImageSize CGSizeValue].height + 3;
    }
    
    // height for tool bar
    height = 5 + height + 16 + 10;
    return height;
}

#pragma mark - 
#pragma mark - Notification
- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(applicationDidBecomeActive) 
                                                 name:UIApplicationDidBecomeActiveNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(applicationWillResignActive) 
                                                 name:UIApplicationWillResignActiveNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(applicationWillEnterForeground) 
                                                 name:UIApplicationWillEnterForegroundNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(applicationWillTerminate)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(refreshTitleView) 
                                                 name:kWeiboUserInfoDidUpdateNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(pushUserInfoViewController:) 
                                                 name:kShowUserInfoNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(pushWebViewController:) 
                                                 name:kTouchedURLNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(showOriginalPic:)
                                                 name:kShowOriginalPicNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(thumbnailPicLoaded:)
                                                 name:kThumbnailPicLoadedNotification
                                               object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIApplicationDidBecomeActiveNotification 
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIApplicationWillResignActiveNotification 
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIApplicationDidEnterBackgroundNotification 
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIApplicationWillTerminateNotification 
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:kWeiboUserInfoDidUpdateNotification 
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:kShowUserInfoNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:kTouchedURLNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:kShowOriginalPicNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kThumbnailPicLoadedNotification
                                                  object:nil];
}

#pragma mark - 
#pragma mark - Notification methods
- (void)applicationDidBecomeActive {
    NSLog(@"%s", __func__);
}

- (void)applicationWillResignActive {
    NSLog(@"%s", __func__);
}

- (void)applicationWillEnterForeground {
    NSLog(@"%s", __func__);
}

- (void)applicationDidEnterBackground {
    NSLog(@"%s", __func__);
    int count = [self.dataArray count];
    if (count > 0) {
        FMDatabase *database = [[DatabaseManager defaultManager] database];
        for (int i = 0; i < count; i++) {
            NSString *sql = @"insert into statuses_data (data) values (?);";
            NSData *data = [self.dataArray objectAtIndex:i];
            [database executeUpdate:sql withArgumentsInArray:@[data]];
        }    
    }
}

- (void)applicationWillTerminate {
    NSLog(@"%s", __func__);
    int count = [self.dataArray count];
    if (count > 0) {
        FMDatabase *database = [[DatabaseManager defaultManager] database];
        for (int i = 0; i < count; i++) {
            NSString *sql = @"insert into statuses_data (data) values (?);";
            NSData *data = [self.dataArray objectAtIndex:i];
            [database executeUpdate:sql withArgumentsInArray:@[data]];
        }    
    }
}

- (void)refreshTitleView {
    WeiboUser *user = [[SinaWeiboManager defaultManager] user];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = user.screenName;
    });
}

- (void)pushUserInfoViewController:(NSNotification *)notification
{
    WeiboUser *user = notification.object;
    UserInfoViewController *viewController = 
    (id)[self.storyboard instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
    viewController.user = user;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)pushWebViewController:(NSNotification *)notification
{
    NSString *urlStr = notification.object;
    WBWebViewController *viewController = 
    (id)[self.storyboard instantiateViewControllerWithIdentifier:@"WBWebViewController"];
    viewController.urlStr = urlStr;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)showOriginalPic:(NSNotification *)notification
{
    WeiboStatus *status = notification.object;
    NSString *urlStr = [status originalPic];
    WBWebViewController *viewController =
    (id)[self.storyboard instantiateViewControllerWithIdentifier:@"WBWebViewController"];
    viewController.urlStr = urlStr;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)thumbnailPicLoaded:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

@end