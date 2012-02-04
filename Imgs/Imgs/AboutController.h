//
//  AboutController.h
//  Imgs
//
//  Created by Eric Florenzano on 1/27/12.
//  Copyright (c) 2012 Boilerplate Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Clutch/Clutch.h>

@interface AboutController : UIViewController <ClutchViewDelegate>

@property (nonatomic, retain) ClutchView *clutchView;

@end
