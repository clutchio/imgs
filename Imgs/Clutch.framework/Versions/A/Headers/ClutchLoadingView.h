//
//  ClutchLoadingView.h
//  Clutch
//
//  Created by Eric Florenzano on 1/6/12.
//  Copyright (c) 2012 Made with Lasers, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ClutchLoadingView : UIView {
    UILabel *loadingLabel;
	UIActivityIndicatorView *spinner;
}

- (void)show:(NSString *)text;
- (void)show:(NSString *)text top:(float)top;
- (void)hide;

@end
