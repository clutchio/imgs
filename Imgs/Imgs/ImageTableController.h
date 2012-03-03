//
//  ImageTableController.h
//  Imgs
//
//  Created by Eric Florenzano on 1/17/12.
//  Copyright (c) 2012 Boilerplate Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Clutch/Clutch.h>
#import "EGORefreshTableHeaderView.h"
#import "JSONKit.h"
#import "AFNetworking.h"
#import <Parse/Parse.h>

@interface ImageTableController : UIViewController <ClutchViewDelegate, UIScrollViewDelegate, EGORefreshTableHeaderDelegate>

@property (nonatomic, retain) ClutchView *clutchView;
@property (nonatomic, retain) NSString *kind;
@property (nonatomic, retain) NSString *displayType;
@property (nonatomic, retain) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, retain) UIView *refreshHider;
@property (nonatomic, retain) NSDate *dateLastUpdated;
@property (nonatomic, assign) BOOL reloading;

- (ImageTableController *)initWithKind:(NSString *)kind;
- (void)doneLoadingTableViewData;
- (void)getJSON:(NSString *)url
        success:(void(^)(id))successBlock_ 
        failure:(void(^)(AFHTTPRequestOperation *))failureBlock_;

@end
