//
//  AsyncXCTestCase.m
//  SinaWeibo
//
//  Created by cxjwin on 14-5-26.
//  Copyright (c) 2014年 cxjwin. All rights reserved.
//

#import "AsyncXCTestCase.h"

@interface AsyncXCTestCase ()

@property (atomic, assign) NSUInteger asyncTestCaseSignaledCount;

@end

static const NSTimeInterval kRunLoopSamplingInterval = 0.01;

@implementation AsyncXCTestCase

- (void)waitForAsyncOperationWithTimeout:(NSTimeInterval)timeout {
	[self waitForAsyncOperations:1 withTimeout:timeout];
}

- (void)waitForAsyncOperations:(NSUInteger)count withTimeout:(NSTimeInterval)timeout {
	NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
	while ((self.asyncTestCaseSignaledCount < count) && ([timeoutDate timeIntervalSinceNow] > 0)) {
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopSamplingInterval, YES);
	}

	// Reset the counter for next time, in case we call this method again later
	// (don't reset it at the beginning of the method because we should be able to call
	// notifyAsyncOperationDone *before* this method if we wanted to)
	self.asyncTestCaseSignaledCount = 0;

	NSTimeInterval timeOut = [timeoutDate timeIntervalSinceNow];
	if (timeOut < 0) {
		// now is after timeoutDate, we timed out
		XCTFail(@"Timed out while waiting for Async Operations to finish.");
	}
}

- (void)waitForTimeout:(NSTimeInterval)timeout {
	NSDate *waitEndDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
	while ([waitEndDate timeIntervalSinceNow] > 0) {
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopSamplingInterval, YES);
	}
}

- (void)notifyAsyncOperationDone {
	@synchronized(self)
	{
		self.asyncTestCaseSignaledCount = self.asyncTestCaseSignaledCount + 1;
	}
}

@end
