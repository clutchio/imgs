//
//  LikeSummaryController.m
//  Imgs
//
//  Created by Eric Florenzano on 1/26/12.
//  Copyright (c) 2012 Boilerplate Inc. All rights reserved.
//

#import "LikeSummaryController.h"

@implementation LikeSummaryController

@synthesize clutchView = _clutchView;
@synthesize image = _image;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - ClutchViewDelegate

- (void)clutchView:(ClutchView *)clutchView methodCalled:(NSString *)method withParams:(NSDictionary *)params callback:(void(^)(id))callback
{
    if([method isEqualToString:@"getInitialData"]) {
        callback([NSDictionary dictionaryWithObjectsAndKeys: self.image, @"image", nil]);
    }
}

#pragma mark - View lifecycle

- (void)loadView
{
    self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.clutchView = [[ClutchView alloc] initWithFrame:CGRectMake(0, 0, 320, 411)
                                                andSlug:@"likesummary"];
    [self.clutchView release];
    self.clutchView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(44, 0, 0, 0);
    self.clutchView.delegate = self;
    [self.view addSubview:self.clutchView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.clutchView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top-bar-blank.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.clutchView viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.clutchView viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
