//
//  AsyncXCTestCase.h
//  SinaWeibo
//
//  Created by cxjwin on 14-5-26.
//  Copyright (c) 2014年 cxjwin. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface AsyncXCTestCase : XCTestCase
/** @note All the waitFor… methods run the current runloop while waiting to let other threads and operations to continue running **/
-(void)waitForAsyncOperationWithTimeout:(NSTimeInterval)timeout; //!< Wait for one async operation
-(void)waitForAsyncOperations:(NSUInteger)count withTimeout:(NSTimeInterval)timeout; //!< Wait for multiple async operations
-(void)waitForTimeout:(NSTimeInterval)timeout; //!< Wait for a fixed amount of time
-(void)notifyAsyncOperationDone; //!< notify any waiter that the async op is done
@end
