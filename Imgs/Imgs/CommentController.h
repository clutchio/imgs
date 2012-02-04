//
//  CommentController.h
//  Imgs
//
//  Created by Eric Florenzano on 1/25/12.
//  Copyright (c) 2012 Boilerplate Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>

typedef void (^JavaScriptCallbackBlock)(id);

@interface CommentController : UIViewController <UITextViewDelegate>

@property (nonatomic, retain) NSDictionary *image;
@property (nonatomic, retain) UIView *bkg;
@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) JavaScriptCallbackBlock callbackBlock;

@end
