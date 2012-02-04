//
//  ClutchView.h
//  Clutch
//
//  Created by Eric Florenzano on 10/17/11.
//  Copyright (c) 2011 Boilerplate Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Clutch/ClutchConf.h>
#import <Clutch/ClutchStats.h>
#import <Clutch/ClutchUtils.h>
#import <Clutch/ClutchLoadingView.h>

@interface ClutchView : UIView <UIScrollViewDelegate, UIWebViewDelegate> {
    UIWebView *_webView;
    UIScrollView *_scrollView;
    NSString *_slug;
    NSMutableArray *_methodQueue;
    ClutchLoadingView *_loadingView;
    id _scrollViewOriginalDelegate;
    id _scrollDelegate;
    id _delegate;
    CFAbsoluteTime _lastBottomReached;
    BOOL _loaded;
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) NSString *slug;
@property (nonatomic, retain) NSMutableArray *methodQueue;
@property (nonatomic, retain) ClutchLoadingView *loadingView;
@property (nonatomic, retain) id scrollViewOriginalDelegate;
@property (nonatomic, retain) id scrollDelegate;
@property (nonatomic, retain) id delegate;
@property (nonatomic, assign) CFAbsoluteTime lastBottomReached;
@property (nonatomic, assign) BOOL loaded;

- (void)loadWebView;
- (void)callMethod:(NSString *)method;
- (void)callMethod:(NSString *)method withParams:(NSDictionary *)params;
- (id)initWithFrame:(CGRect)frame andSlug:(NSString *)slug;
- (void)viewDidAppear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;
+ (void)logDeviceIdentifier;
+ (NSString *)getDeviceIdentifier;
+ (void)prepareForAnimation:(UIViewController *)viewController success:(void(^)(void))block_;

@end

@protocol ClutchViewDelegate
@optional
- (void)clutchView:(ClutchView *)clutchView methodCalled:(NSString *)method withParams:(NSDictionary *)params;
- (void)clutchView:(ClutchView *)clutchView methodCalled:(NSString *)method withParams:(NSDictionary *)params callback:(void(^)(id))callback;
@end
