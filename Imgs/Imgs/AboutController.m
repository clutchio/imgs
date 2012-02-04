//
//  AboutController.m
//  Imgs
//
//  Created by Eric Florenzano on 1/27/12.
//  Copyright (c) 2012 Boilerplate Inc. All rights reserved.
//

#import "AboutController.h"

@implementation AboutController

@synthesize clutchView = _clutchView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - ClutchViewDelegate

- (void)clutchView:(ClutchView *)clutchView methodCalled:(NSString *)method withParams:(NSDictionary *)params callback:(void(^)(id))callback {

}

#pragma mark - View lifecycle

- (void) loadView
{
    self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bkg.png"]];
    
    self.navigationController.navigationBar.translucent = TRUE;
    
    self.navigationItem.title = @"About Imgs";
    self.clutchView = [[ClutchView alloc] initWithFrame:CGRectMake(0, 0, 320, 411)
                                                andSlug:@"about"];
    [self.clutchView release];
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
    [self.clutchView loadWebView];
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
