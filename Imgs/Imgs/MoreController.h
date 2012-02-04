//
//  AboutController.h
//  Imgs
//
//  Created by Eric Florenzano on 1/24/12.
//  Copyright (c) 2012 Boilerplate Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Clutch/Clutch.h>
#import <MessageUI/MessageUI.h>

@interface MoreController : UIViewController <ClutchViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) ClutchView *clutchView;

@end
