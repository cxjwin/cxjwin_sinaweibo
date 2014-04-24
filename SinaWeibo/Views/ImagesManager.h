//
//  ImagesManager.h
//  SinaWeibo
//
//  Created by 蔡 雪钧 on 14-4-13.
//  Copyright (c) 2014年 cxjwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImagesManager : NSObject

@property (nonatomic, strong, readonly) NSArray *imageURLs;

- (instancetype)initWithURLs:(NSArray *)URLs;

- (NSMutableArray *)KVOImages;

- (NSUInteger)countOfImages;

- (id)objectInImagesAtIndex:(NSUInteger)index;

- (void)insertObject:(id)obj inImagesAtIndex:(NSUInteger)index;

- (void)removeObjectFromImagesAtIndex:(NSUInteger)index;

- (void)replaceObjectInImagesAtIndex:(NSUInteger)index withObject:(id)obj;

@end