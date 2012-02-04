//
//  LoginController.h
//  Imgs
//
//  Created by Eric Florenzano on 1/24/12.
//  Copyright (c) 2012 Boilerplate Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Clutch/Clutch.h>
#import <Parse/Parse.h>

@interface LoginOptionController : UIViewController <ClutchViewDelegate, PF_FBRequestDelegate>

@property (nonatomic, retain) ClutchView *clutchView;

@end
