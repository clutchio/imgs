//
//  LoginController.m
//  Imgs
//
//  Created by Eric Florenzano on 1/24/12.
//  Copyright (c) 2012 Boilerplate Inc. All rights reserved.
//

#import "LoginOptionController.h"
#import "LoginController.h"
#import "RegisterController.h"

@implementation LoginOptionController

@synthesize clutchView = _clutchView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)logInWithFacebook
{
    PFUser *currentUser = [PFUser currentUser];
    if(currentUser) {
        [currentUser linkToFacebook:nil block:^(BOOL succeeded, NSError *error) {
            if(succeeded) {
                if([currentUser objectForKey:@"name"]) {
                    [self.navigationController dismissModalViewControllerAnimated:YES];
                } else {
                    [[PFUser facebook] requestWithGraphPath:@"me" andDelegate:self];
                }
            } else {
                NSLog(@"Uh oh. The user cancelled the Facebook linking.");
            }
        }];
    } else {
        [PFUser logInWithFacebook:nil block:^(PFUser *user, NSError *error) {
            if(user) {
                if([user objectForKey:@"name"]) {
                    [self.navigationController dismissModalViewControllerAnimated:YES];
                } else {
                    [[PFUser facebook] requestWithGraphPath:@"me" andDelegate:self];
                }
            } else {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            }
        }];
    }
}

- (void)request:(PF_FBRequest *)request didLoad:(id)result
{
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setObject:[result objectForKey:@"name"] forKey:@"name"];
    NSString *username = [result objectForKey:@"username"];
    if(username) {
        [currentUser setObject:username forKey:@"fb_username"];
    }
    [currentUser saveInBackground];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)request:(PF_FBRequest *)request didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook error" 
                                                    message:@"Facebook has failed to respond properly, please try again." 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)cancelTapped
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark - ClutchViewDelegate

- (void)clutchView:(ClutchView *)clutchView methodCalled:(NSString *)method withParams:(NSDictionary *)params
{
    if([method isEqualToString:@"login"]) {
        LoginController *loginController = [[[LoginController alloc] init] autorelease];
        [ClutchView prepareForAnimation:loginController success:^{
            [self.navigationController pushViewController:loginController animated:YES];
        }];
    } else if([method isEqualToString:@"register"]) {
        RegisterController *registerController = [[[RegisterController alloc] init] autorelease];
        [ClutchView prepareForAnimation:registerController success:^{
            [self.navigationController pushViewController:registerController animated:YES];
        }];
    } else if([method isEqualToString:@"facebook"]) {
        [self logInWithFacebook];
    }
}

#pragma mark - View lifecycle

- (void) loadView
{
    self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bkg.png"]];
    
    self.navigationItem.title = @"Login or Register";
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(cancelTapped)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    [cancelButton release];
    
    self.clutchView = [[ClutchView alloc] initWithFrame:CGRectMake(0, 44, 320, 416)
                                                andSlug:@"loginoption"];
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
