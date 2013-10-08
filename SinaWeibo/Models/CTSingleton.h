//
//  CTSingleton.h
//  CoreTextDemo
//
//  Created by cxjwin on 13-8-28.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

#define kLineSpacing 4.0f
#define kContentTextSize 13.0f

extern CGFloat kContentTextWidth;
extern NSString *const kCustomGlyphTypeAttributeName;
extern NSString *const kCustomGlyphRangeAttributeName;
extern NSString *const kCustomGlyphImageAttributeName;
extern NSString *const kCustomGlyphInfoAttribute;

typedef enum CustomGlyphType {
  CustomGlyphURL = 0,
  CustomGlyphAt,
  CustomGlyphTopic,
  CustomGlyphImage,
  CustomGlyphGif,
  CustomGlyphInfoImage
}CustomGlyphType;

typedef struct CustomGlyphMetrics {
  CGFloat ascent;
  CGFloat descent;
  CGFloat width;
}CustomGlyphMetrics, *CustomGlyphMetricsRef;

@interface GifObject : NSObject
 
@property (strong, nonatomic) NSMutableArray *animationImages;
@property (assign, nonatomic) NSTimeInterval intervalTime;

@end

@interface CTSingleton : NSObject

@property (strong, nonatomic) NSCache *gifCache;
@property (strong, nonatomic) NSDictionary *emojiDict;

+ (id)sharedInstance;

//- (id)gifSourceWithName:(NSString *)gifName;

- (NSMutableAttributedString *)transformText:(NSString *)text; 
- (NSValue *)sizeValueWithAttributedText:(NSMutableAttributedString *)attributedText;

@end
