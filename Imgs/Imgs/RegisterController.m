//
//  RegisterController.m
//  Imgs
//
//  Created by Eric Florenzano on 1/25/12.
//  Copyright (c) 2012 Boilerplate Inc. All rights reserved.
//

#import "RegisterController.h"

@implementation RegisterController

@synthesize clutchView = _clutchView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)registerWithUsername:(NSString *)username password:(NSString *)password email:(NSString *)email
{
    PFUser *user = [PFUser user];
    user.username = username;
    user.password = password;
    user.email = email;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error) {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't register" 
                                                            message:errorString 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        } else {
            [self.navigationController dismissModalViewControllerAnimated:YES];
        }
    }];
}

- (void)cancelTapped
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark - ClutchViewDelegate

- (void)clutchView:(ClutchView *)clutchView methodCalled:(NSString *)method withParams:(NSDictionary *)params
{
    if([method isEqualToString:@"submit"]) {
        [self registerWithUsername:[params objectForKey:@"username"]
                          password:[params objectForKey:@"password"]
                             email:[params objectForKey:@"email"]];
    }
}

#pragma mark - View lifecycle

- (void)loadView
{
    self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bkg.png"]];
    
    self.navigationItem.title = @"Register";
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(cancelTapped)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    [cancelButton release];
    
    self.clutchView = [[ClutchView alloc] initWithFrame:CGRectMake(0, 44, 320, 372)
                                                andSlug:@"register"];
    [self.clutchView release];
    self.clutchView.delegate = self;
    self.clutchView.scrollView.scrollEnabled = NO;
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
