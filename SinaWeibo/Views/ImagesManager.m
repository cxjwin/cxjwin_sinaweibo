//
//  ImagesManager.m
//  SinaWeibo
//
//  Created by cxjwin on 14-4-13.
//  Copyright (c) 2014 cxjwin. All rights reserved.
//

#import <SDWebImage/SDWebImageManager.h>
#import "ImagesManager.h"

@interface ImagesManager ()

@property (nonatomic, strong) NSMutableArray *images;

@end

@implementation ImagesManager

- (instancetype)initWithURLs:(NSArray *)URLs {
    self = [super init];
    if (self) {
        NSAssert([URLs count] > 1, @"count > 1");
        _imageURLs = URLs;
        self.images = [NSMutableArray arrayWithCapacity:[URLs count]];
        
        [self setUpImagesWithURLs:URLs];
    }
    return self;
}

- (void)setUpImagesWithURLs:(NSArray *)URLs {
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    for (NSURL *URL in URLs) {
        UIImage *image = [manager.imageCache imageFromMemoryCacheForKey:[URL absoluteString]];
        if (image) {
            [self.KVOImages addObject:image];
        } else {
            [self.KVOImages addObject:[NSNull null]];
            
            __weak typeof(self) weakSelf = self;
            __block NSUInteger index = [URLs indexOfObject:URL];
            void (^completed)(UIImage *, NSError *, SDImageCacheType, BOOL) = ^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
				if (image) {
                    [weakSelf replaceObjectInImagesAtIndex:index withObject:image];
				}
			};
			[manager downloadWithURL:URL options:SDWebImageCacheMemoryOnly progress:nil completed:completed];
        }
    }
}

- (NSUInteger)countOfImages {
    return [self.images count];
}

- (id)objectInImagesAtIndex:(NSUInteger)index {
    return [self.images objectAtIndex:index];
}

- (void)insertObject:(id)obj inImagesAtIndex:(NSUInteger)index {
    [self.images insertObject:obj atIndex:index];
}

- (void)removeObjectFromImagesAtIndex:(NSUInteger)index {
    [self.images removeObjectAtIndex:index];
}

- (void)replaceObjectInImagesAtIndex:(NSUInteger)index withObject:(id)obj {
    [self.images replaceObjectAtIndex:index withObject:obj];
}

- (NSMutableArray *)KVOImages {
    return [self mutableArrayValueForKey:@"images"];
}

@end
