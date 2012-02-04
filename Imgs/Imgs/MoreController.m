//
//  AboutController.m
//  Imgs
//
//  Created by Eric Florenzano on 1/24/12.
//  Copyright (c) 2012 Boilerplate Inc. All rights reserved.
//

#import "MoreController.h"
#import "LoginOptionController.h"
#import "AboutController.h"
#import "SHK.h"
#import <Parse/Parse.h>

@implementation MoreController

@synthesize clutchView = _clutchView;

- (MoreController *)init
{
    self = [super init];
    if (self) {
        self.title = @"More";
        self.tabBarItem.image = [UIImage imageNamed:@"more-icon.png"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (NSDictionary *)getUserData:(PFUser *)user
{
    NSString *username = [user objectForKey:@"fb_username"];
    if(!username) {
        username = [user objectForKey:@"name"];
    }
    if(!username) {
        username = [user objectForKey:@"username"];
    }
    if(!username) {
        username = @"Unknown User";
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:
            username, @"username",
            user.objectId, @"id",
            nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
	[self becomeFirstResponder];
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark - ClutchViewDelegate

- (void)clutchView:(ClutchView *)clutchView methodCalled:(NSString *)method withParams:(NSDictionary *)params callback:(void(^)(id))callback {
    // This is where we inspect the method called and handle callbacks
    if([method isEqualToString:@"getInitialData"]) {
        PFUser *user = [PFUser currentUser];
        callback([NSDictionary dictionaryWithObjectsAndKeys:
                  user ? [self getUserData:user] : [NSNull null], @"user",
                  nil]);
    } else if([method isEqualToString:@"logoutTapped"]) {
        [PFUser logOut];
    } else if([method isEqualToString:@"loginTapped"]) {
        LoginOptionController *login = [[[LoginOptionController alloc] init] autorelease];
        [ClutchView prepareForAnimation:login success:^{
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:login];
            nav.navigationBar.translucent = YES;
            [self presentModalViewController:nav animated:YES];
            [nav release];
        }];
    } else if([method isEqualToString:@"aboutTapped"]) {
        AboutController *aboutController = [[[AboutController alloc] init] autorelease];
        [ClutchView prepareForAnimation:aboutController success:^{
            [self.navigationController pushViewController:aboutController animated:YES];
        }];
    } else if([method isEqualToString:@"sendTapped"]) {
        NSURL *url = [NSURL URLWithString:[params objectForKey:@"url"]];
        SHKItem *item = [SHKItem URL:url title:[params objectForKey:@"title"]];
        SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
        [actionSheet showFromTabBar:self.navigationController.tabBarController.tabBar];
    } else if([method isEqualToString:@"emailTapped"]) {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:[params objectForKey:@"subject"]];
        [controller setToRecipients:[NSArray arrayWithObject:[params objectForKey:@"to"]]];
        [controller setMessageBody:[params objectForKey:@"body"]
                            isHTML:[[params objectForKey:@"isHTML"] boolValue]];
        [self.navigationController presentViewController:controller animated:YES completion:nil];
        [controller release];
    }
}

#pragma mark - View lifecycle

- (void) loadView
{
    self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bkg.png"]];
    
    self.navigationController.navigationBar.translucent = TRUE;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top-bar.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
    
    self.navigationItem.title = @"More";
    self.clutchView = [[ClutchView alloc] initWithFrame:CGRectMake(0, 0, 320, 411)
                                                andSlug:@"more"];
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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top-bar.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
    PFUser *user = [PFUser currentUser];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            user ? [self getUserData:user] : [NSNull null], @"user",
                            nil];
    [self.clutchView callMethod:@"setData" withParams:params];
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
