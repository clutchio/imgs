//
//  AppDelegate.h
//  Imgs
//
//  Created by Eric Florenzano on 1/17/12.
//  Copyright (c) 2012 Boilerplate Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Clutch/Clutch.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

@end
