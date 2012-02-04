//
//  LoginController.h
//  Imgs
//
//  Created by Eric Florenzano on 1/25/12.
//  Copyright (c) 2012 Boilerplate Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Clutch/Clutch.h>
#import <Parse/Parse.h>

@interface LoginController : UIViewController <ClutchViewDelegate>

@property (nonatomic, retain) ClutchView *clutchView;

@end
