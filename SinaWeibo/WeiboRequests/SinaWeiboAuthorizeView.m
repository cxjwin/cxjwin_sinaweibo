//
//  SinaWeiboAuthorizeView.m
//  sinaweibo_ios_sdk
//
//  Created by Wade Cheng on 4/19/12.
//  Copyright (c) 2012 SINA. All rights reserved.
//

#import "SinaWeiboAuthorizeView.h"
#import "RequestUtils.h"
#import "SinaWeiboManager.h"
#import "SinaWeiboConstants.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat kBorderGray[4] = {0.3, 0.3, 0.3, 0.8};
static CGFloat kBorderBlack[4] = {0.3, 0.3, 0.3, 1};
static CGFloat kTransitionDuration = 0.3;
static CGFloat kPadding = 0;
static CGFloat kBorderWidth = 10;

@implementation SinaWeiboAuthorizeView

#pragma mark - Drawing

- (void)addRoundedRectToPath:(CGContextRef)context rect:(CGRect)rect radius:(float)radius {
  CGContextBeginPath(context);
  CGContextSaveGState(context);
  
  if (radius == 0) {
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddRect(context, rect);
  } else {
    rect = CGRectOffset(CGRectInset(rect, 0.5, 0.5), 0.5, 0.5);
    CGContextTranslateCTM(context, CGRectGetMinX(rect)-0.5, CGRectGetMinY(rect)-0.5);
    CGContextScaleCTM(context, radius, radius);
    float fw = CGRectGetWidth(rect) / radius;
    float fh = CGRectGetHeight(rect) / radius;
    
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
  }
  
  CGContextClosePath(context);
  CGContextRestoreGState(context);
}

- (void)drawRect:(CGRect)rect fill:(const CGFloat*)fillColors radius:(CGFloat)radius {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
  
  if (fillColors) {
    CGContextSaveGState(context);
    CGContextSetFillColor(context, fillColors);
    if (radius) {
      [self addRoundedRectToPath:context rect:rect radius:radius];
      CGContextFillPath(context);
    } else {
      CGContextFillRect(context, rect);
    }
    CGContextRestoreGState(context);
  }
  CGColorSpaceRelease(space);
}

- (void)strokeLines:(CGRect)rect stroke:(const CGFloat*)strokeColor {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
  
  CGContextSaveGState(context);
  CGContextSetStrokeColorSpace(context, space);
  CGContextSetStrokeColor(context, strokeColor);
  CGContextSetLineWidth(context, 1.0);
  
  {
    CGPoint points[] = {{rect.origin.x+0.5, rect.origin.y-0.5},
      {rect.origin.x+rect.size.width, rect.origin.y-0.5}};
    CGContextStrokeLineSegments(context, points, 2);
  }
  {
    CGPoint points[] = {{rect.origin.x+0.5, rect.origin.y+rect.size.height-0.5},
      {rect.origin.x+rect.size.width-0.5, rect.origin.y+rect.size.height-0.5}};
    CGContextStrokeLineSegments(context, points, 2);
  }
  {
    CGPoint points[] = {{rect.origin.x+rect.size.width-0.5, rect.origin.y},
      {rect.origin.x+rect.size.width-0.5, rect.origin.y+rect.size.height}};
    CGContextStrokeLineSegments(context, points, 2);
  }
  {
    CGPoint points[] = {{rect.origin.x+0.5, rect.origin.y},
      {rect.origin.x+0.5, rect.origin.y+rect.size.height}};
    CGContextStrokeLineSegments(context, points, 2);
  }
  
  CGContextRestoreGState(context);
  
  CGColorSpaceRelease(space);
}

- (void)drawRect:(CGRect)rect {
  [self drawRect:rect fill:kBorderGray radius:0];
  CGRect webRect = CGRectMake(ceil(rect.origin.x+kBorderWidth), ceil(rect.origin.y+kBorderWidth)+1,
                              rect.size.width-kBorderWidth*2, rect.size.height-(1+kBorderWidth*2));
  [self strokeLines:webRect stroke:kBorderBlack];
}

#pragma mark - Memory management

- (id)init {
  if ((self = [super init])) {
    self.backgroundColor = [UIColor clearColor];
    self.autoresizesSubviews = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.contentMode = UIViewContentModeRedraw;
    
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.webView];
    
    UIImage* closeImage = [UIImage imageNamed:@"close.png"];
    UIColor* color = [UIColor colorWithRed:167.0/255 green:184.0/255 blue:216.0/255 alpha:1];
    closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:closeImage forState:UIControlStateNormal];
    [closeButton setTitleColor:color forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [closeButton addTarget:self action:@selector(cancel)
          forControlEvents:UIControlEventTouchUpInside];
    closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    closeButton.showsTouchWhenHighlighted = YES;
    closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:closeButton];
    
    indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                     UIActivityIndicatorViewStyleGray];
    indicatorView.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:indicatorView];
    
    modalBackgroundView = [[UIView alloc] init];
  }
  
  return self;
}

- (id)initWithAuthParams:(NSDictionary *)params
                delegate:(id<SinaWeiboAuthorizeViewDelegate>)delegate {
  if ((self = [self init])) {
    self.delegate = delegate;
    self.authParams = params;
    self.appRedirectURI = [self.authParams objectForKey:@"redirect_uri"];
  }
  return self;
}

#pragma mark - View orientation

- (BOOL)shouldRotateToOrientation:(UIInterfaceOrientation)orientation {
  if (orientation == previousOrientation) {
    return NO;
  } else {
    return (orientation == UIInterfaceOrientationPortrait ||
            orientation == UIInterfaceOrientationPortraitUpsideDown || 
            orientation == UIInterfaceOrientationLandscapeLeft || 
            orientation == UIInterfaceOrientationLandscapeRight);
  }
}

- (CGAffineTransform)transformForOrientation {
  UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
  if (orientation == UIInterfaceOrientationLandscapeLeft) {
    return CGAffineTransformMakeRotation(M_PI*1.5);
  } else if (orientation == UIInterfaceOrientationLandscapeRight) {
    return CGAffineTransformMakeRotation(M_PI/2);
  } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
    return CGAffineTransformMakeRotation(-M_PI);
  } else {
    return CGAffineTransformIdentity;
  }
}

- (void)sizeToFitOrientation:(BOOL)transform {
  if (transform) {
    self.transform = CGAffineTransformIdentity;
  }
  
  CGRect frame = [UIScreen mainScreen].applicationFrame;
  CGPoint center = CGPointMake(frame.origin.x + ceil(frame.size.width/2),
                               frame.origin.y + ceil(frame.size.height/2));
  
  CGFloat scaleFactor = 1;
  
  CGFloat width = floor(scaleFactor * frame.size.width) - kPadding * 2;
  CGFloat height = floor(scaleFactor * frame.size.height) - kPadding * 2;
  
  previousOrientation = [UIApplication sharedApplication].statusBarOrientation;
  if (UIInterfaceOrientationIsLandscape(previousOrientation)) {
    self.frame = CGRectMake(kPadding, kPadding, height, width);
  }
  else {
    self.frame = CGRectMake(kPadding, kPadding, width, height);
  }
  self.center = center;
  
  if (transform) {
    self.transform = [self transformForOrientation];
  }
}

- (void)updateWebOrientation {
  UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
  if (UIInterfaceOrientationIsLandscape(orientation)) {
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.setAttribute('orientation', 90);"];
  } else {
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.removeAttribute('orientation');"];
  }
}

#pragma mark - UIDeviceOrientationDidChangeNotification Methods

- (void)deviceOrientationDidChange:(id)object {
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if ([self shouldRotateToOrientation:orientation]) {
    NSTimeInterval duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[self sizeToFitOrientation:orientation];
		[UIView commitAnimations];
	}
}

#pragma mark - Animation
- (void)bounce1AnimationStopped {
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:kTransitionDuration * 0.5];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
  self.transform = CGAffineTransformScale([self transformForOrientation], 0.9, 0.9);
  [UIView commitAnimations];
}

- (void)bounce2AnimationStopped {
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:kTransitionDuration * 0.5];
  self.transform = [self transformForOrientation];
  [UIView commitAnimations];
}

#pragma mark Obeservers

- (void)addObservers {
	[[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(deviceOrientationDidChange:)
                                               name:@"UIDeviceOrientationDidChangeNotification"
                                             object:nil];
}

- (void)removeObservers {
	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:@"UIDeviceOrientationDidChangeNotification"
                                                object:nil];
}

#pragma mark - Activity Indicator

- (void)showIndicator {
  [indicatorView sizeToFit];
  [indicatorView startAnimating];
  indicatorView.center = self.webView.center;	
}

- (void)hideIndicator {
  [indicatorView stopAnimating];
}

#pragma mark - Show / Hide

- (void)load {
  NSString *authPagePath = [RequestUtils serializeURL:kSinaWeiboWebAuthURL
                                               params:self.authParams];
  [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:authPagePath]]];
}

- (void)showWebView {
  UIWindow* window = [UIApplication sharedApplication].keyWindow;	
  if (!window)
  {	
    window = [[UIApplication sharedApplication].windows objectAtIndex:0];	
  }	
  modalBackgroundView.frame = window.frame;	
  [modalBackgroundView addSubview:self];	
  [window addSubview:modalBackgroundView];	
  
  self.transform = CGAffineTransformScale([self transformForOrientation], 0.001, 0.001);	
  [UIView beginAnimations:nil context:nil];	
  [UIView setAnimationDuration:kTransitionDuration/1.5];	
  [UIView setAnimationDelegate:self];	
  [UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];	
  self.transform = CGAffineTransformScale([self transformForOrientation], 1.1, 1.1);	
  [UIView commitAnimations];	
}

- (void)show {
  [self load];
  [self sizeToFitOrientation:NO];
  
  CGFloat innerWidth = self.frame.size.width - (kBorderWidth+1)*2;
  [closeButton sizeToFit];
  closeButton.frame = CGRectMake(2, 2, 29, 29);
  
  self.webView.frame = CGRectMake(kBorderWidth+1, kBorderWidth+1, innerWidth,
                             self.frame.size.height - (1 + kBorderWidth*2));
  
  [self showWebView];
  [self showIndicator];
  
  [self addObservers];
}

- (void)_hide
{
  [self removeFromSuperview];
  [modalBackgroundView removeFromSuperview];
}

- (void)hide
{
  [self removeObservers];
  
  [self.webView stopLoading];
  
  [self performSelectorOnMainThread:@selector(_hide) withObject:nil waitUntilDone:NO];
}

- (void)cancel
{
  [self hide];
  [self.delegate authorizeViewDidCancel:self];
}

#pragma mark - UIWebView Delegate

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
	[self hideIndicator];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
  [self hideIndicator];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    WBLog(@"%@", request.URL);
    
  NSString *url = request.URL.absoluteString;
  
  NSString *siteRedirectURI = [NSString stringWithFormat:@"%@%@", kSinaWeiboSDKOAuth2APIDomain, self.appRedirectURI];
  
  if ([url hasPrefix:self.appRedirectURI] || [url hasPrefix:siteRedirectURI]) {
    NSString *error_code = [RequestUtils getParamValueFromURL:url paramName:@"error_code"];
    if (error_code) {
      NSString *error = [RequestUtils getParamValueFromURL:url paramName:@"error"];
      NSString *error_uri = [RequestUtils getParamValueFromURL:url paramName:@"error_uri"];
      NSString *error_description = [RequestUtils getParamValueFromURL:url paramName:@"error_description"];
      
      NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                 error, @"error",
                                 error_uri, @"error_uri",
                                 error_code, @"error_code",
                                 error_description, @"error_description", nil];
      [self hide];
      [self.delegate authorizeView:self didFailWithErrorInfo:errorInfo];
    } else {
      NSString *code = [RequestUtils getParamValueFromURL:url paramName:@"code"];
      if (code) {
        [self hide];
        [self.delegate authorizeView:self didRecieveAuthorizationCode:code];
      }
    }
    return NO;
  }
  return YES;
}

@end