//
//  SinaWeiboRequests.m
//  SinaWeibo
//
//  Created by cxjwin on 13-8-19.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import "SinaWeiboCommunicator.h"
#import "RequestUtils.h"
#import "SinaWeiboManager.h"

NSString *const kWeiboBackgroundSessionIdentifier = @"kWeiboBackgroundSessionIdentifier";
NSTimeInterval kDefaultTimeoutIntervalForResource = 60;

@implementation SinaWeiboCommunicator : NSObject

- (id)init {
	self = [super init];
	if (self) {
		self.completionHandlerDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
		self.operationQueue = [[NSOperationQueue alloc] init];
		// defaultConfigObject
		{
			NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
			defaultConfigObject.timeoutIntervalForResource = kDefaultTimeoutIntervalForResource;
			NSString *cachePath = @"WeiboCacheDirectory";
#ifdef DEBUG
			/*
			NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
			NSString *myPath = [myPathList objectAtIndex:0];
			NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
			NSString *fullCachePath = [[myPath stringByAppendingPathComponent:bundleIdentifier] stringByAppendingPathComponent:cachePath];
			WBLog(@"Cache path: %@\n", fullCachePath);
			 */
#endif
			NSURLCache *myCache =
			    [[NSURLCache alloc] initWithMemoryCapacity:kOneMegaByte diskCapacity:256 * kOneMegaByte diskPath:cachePath];
			defaultConfigObject.URLCache = myCache;
			defaultConfigObject.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
			self.defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:self delegateQueue:self.operationQueue];
		}
		// ephemeralConfigObject
		{
			NSURLSessionConfiguration *ephemeralConfigObject = [NSURLSessionConfiguration ephemeralSessionConfiguration];
			ephemeralConfigObject.timeoutIntervalForResource = kDefaultTimeoutIntervalForResource;
			self.ephemeralSession = [NSURLSession sessionWithConfiguration:ephemeralConfigObject delegate:nil delegateQueue:self.operationQueue];
		}
		// backgroundConfigObject
		{
			NSURLSessionConfiguration *backgroundConfigObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:kWeiboBackgroundSessionIdentifier];
			backgroundConfigObject.timeoutIntervalForResource = kDefaultTimeoutIntervalForResource;
			self.backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfigObject delegate:self delegateQueue:self.operationQueue];
		}
	}

	return self;
}

- (NSString *)token {
	return [[SinaWeiboManager defaultManager] accessToken];
}

#pragma mark -
#pragma mark -
- (void)getAccessTokenWithAuthorizationCode:(NSString *)code completionHandler:(DataCompletionHandler)handler {
	NSDictionary *params = @{@"client_id" : kAppKey,
		                     @"client_secret" : kAppSecret,
		                     @"grant_type" : @"authorization_code",
		                     @"redirect_uri" : kAppRedirectURI,
		                     @"code" : code};
	NSString *urlStr = [RequestUtils serializeURL:kSinaWeiboWebAccessTokenURL params:params];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
	request.HTTPMethod = @"POST";

	dispatch_async(dispatch_get_main_queue(), ^{
	    [[self.ephemeralSession dataTaskWithRequest:request completionHandler:handler] resume];
	});
}

- (void)getUserInfoWithID:(NSString *)userID completionHandler:(DataCompletionHandler)handler {
	NSString *baseURL = [kSinaWeiboSDKAPIDomain stringByAppendingString:@"users/show.json"];
	NSDictionary *params = @{@"access_token" : [self token],
		                     @"uid" : userID};
	NSString *URLStr = [RequestUtils serializeURL:baseURL params:params];
	NSURL *URL = [NSURL URLWithString:URLStr];
	NSURLRequest *request = [NSURLRequest requestWithURL:URL];
	[self.ephemeralSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
	    BOOL isLoading = NO;
	    if ([dataTasks count] > 0) {
	        for (NSURLSessionDataTask * task in dataTasks) {
	            if ([task.currentRequest isEqual:request]) {
	                isLoading = YES;
				}
			}
		}

	    if (isLoading == NO) {
	        [[self.ephemeralSession dataTaskWithRequest:request completionHandler:handler] resume];
		}
	}];
}

- (void)getWeiboStatusesWithPage:(int)page completionHandler:(DataCompletionHandler)handler {
	NSString *baseURL = [kSinaWeiboSDKAPIDomain stringByAppendingString:@"statuses/home_timeline.json"];
	NSDictionary *params = @{@"access_token" : [self token],
		                     @"page" : [@(page)stringValue]};
	NSString *URLStr = [RequestUtils serializeURL:baseURL params:params];
	NSURL *URL = [NSURL URLWithString:URLStr];
	NSURLRequest *request = [NSURLRequest requestWithURL:URL];
	[[self.ephemeralSession dataTaskWithRequest:request completionHandler:handler] resume];
}

- (void)downloadImageWithURL:(NSURL *)URL downloadCompletionHandler:(DataCompletionHandler)handler {
	NSAssert(URL, @"URL should not be nil");
	NSURLRequest *request = [NSURLRequest requestWithURL:URL];
	[[self.defaultSession dataTaskWithRequest:request completionHandler:handler] resume];
}

#pragma mark -
#pragma mark - NSURLSessionDelegate

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
	WBLog(@"Background URL session %@ finished events.\n", session);
	if (session.configuration.identifier &&
	    [session.configuration.identifier isEqualToString:kWeiboBackgroundSessionIdentifier]) {
		[session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
		    if ([downloadTasks count] > 0) {
		        NSURLSessionDownloadTask *downloadTask = [downloadTasks objectAtIndex:0];
		        WBLog(@"first download task : %@", downloadTask);
			}
		}];
	}
}

#pragma mark -
#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
	NSString *filePath = nil;
	NSError *error = nil;
	if ([location getResourceValue:&filePath forKey:NSURLPathKey error:&error]) {
		WBLog(@"location file path : %@", filePath);
	} else {
		WBLog(@"error : %@", [error localizedDescription]);
	}

	WBLog(@"Session %@ download task %@ finished downloading to URL %@\n",
	      session, downloadTask, location);

	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *cacheDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
	NSURL *cacheDirURL = [NSURL fileURLWithPath:cacheDir];
	if ([fileManager moveItemAtURL:location
	                         toURL:cacheDirURL
	                         error:&error]) {
		/* Store some reference to the new URL */
	} else {
		/* Handle the error. */
		WBLog(@"error : %@", [error localizedDescription]);
	}
}

- (void)           URLSession:(NSURLSession *)session
                 downloadTask:(NSURLSessionDownloadTask *)downloadTask
                 didWriteData:(int64_t)bytesWritten
            totalBytesWritten:(int64_t)totalBytesWritten
    totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;
{
	WBLog(@"Session %@ download task %@ wrote an additional %lld bytes (total %lld bytes) out of an expected %lld bytes.\n",
	      session, downloadTask, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
}

- (void)    URLSession:(NSURLSession *)session
          downloadTask:(NSURLSessionDownloadTask *)downloadTask
     didResumeAtOffset:(int64_t)fileOffset
    expectedTotalBytes:(int64_t)expectedTotalBytes {
	WBLog(@"Session %@ download task %@ resumed at offset %lld bytes out of an expected %lld bytes.\n",
	      session, downloadTask, fileOffset, expectedTotalBytes);
}

#pragma mark -
#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler {
	WBLog(@"Session : %@, dataTask : %@, willCacheResponse %@.", session, dataTask, proposedResponse);
}

@end
