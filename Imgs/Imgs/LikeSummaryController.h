//
//  LikeSummaryController.h
//  Imgs
//
//  Created by Eric Florenzano on 1/26/12.
//  Copyright (c) 2012 Boilerplate Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Clutch/Clutch.h>

@interface LikeSummaryController : UIViewController <ClutchViewDelegate>

@property (nonatomic, retain) ClutchView *clutchView;
@property (nonatomic, retain) NSDictionary *image;

@end
