//
// Copyright 2012 Twitter
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "ImageDetailController.h"
#import "LoginOptionController.h"
#import "CommentController.h"
#import "LikeSummaryController.h"
#import "EGOPhotoGlobal.h"
#import "SHK.h"
#import "Appirater.h"

@implementation ImageDetailController

@synthesize clutchView = _clutchView;
@synthesize image = _image;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Other Stuff

- (void)setupLoginButton
{
    PFUser *user = [PFUser currentUser];
    
    // If there's a user, set the right nav button to nothing
    if(user) {
        self.navigationItem.rightBarButtonItem = nil;
        return;
    }
    
    // Otherwise there's no logged in user, so show a login button
    UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:@"Log In" 
                                                                    style:UIBarButtonItemStyleBordered 
                                                                   target:self 
                                                                   action:@selector(ensureUser)];
    self.navigationItem.rightBarButtonItem = loginButton;
    [loginButton release];
}


- (PFUser *)ensureUser
{
    PFUser *user = [PFUser currentUser];
    // If there's a current, logged-in user, then return it
    if(user) {
        return user;
    }
    
    // Otherwise pop up a login screen
    LoginOptionController *login = [[[LoginOptionController alloc] init] autorelease];
    [ClutchView prepareForAnimation:login success:^{
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:login];
        [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"top-bar-blank.png"]
                                                    forBarMetrics:UIBarMetricsDefault];
        nav.navigationBar.translucent = YES;
        [self presentModalViewController:nav animated:YES];
        [nav release];
    }];
    
    // Since there is no user, we return nil
    return nil;
}

- (NSDictionary *)getUserData:(PFUser *)user
{
    // First we check if they have a Facebook username
    NSString *username = [user objectForKey:@"fb_username"];
    // If they don't have one of those, then we see if they entered in their name
    if(!username) {
        username = [user objectForKey:@"name"];
    }
    // If they don't have one of those, then we just use their username
    if(!username) {
        username = [user objectForKey:@"username"];
    }
    // If they somehow don't have a username, then we just write "Unknown User"
    if(!username) {
        username = @"Unknown User";
    }
    
    // Return the chosen name along with the user ID
    return [NSDictionary dictionaryWithObjectsAndKeys:
            username, @"username",
            user.objectId, @"id",
            nil];
}

- (void)likeTappedForImage:(NSDictionary *)image callback:(void(^)(id))callback
{
    // If there's no logged-in user, then we shouldn't do anything
    PFUser *user = [self ensureUser];
    if(!user) {
        return;
    }
    
    // Clicking like counts as a "significant event" in my eyes
    [Appirater userDidSignificantEvent:YES];
    
    // Query to find an existing like for this image by this user
    PFQuery *query = [PFQuery queryWithClassName:@"Like"];
    [query whereKey:@"hash" equalTo:[image objectForKey:@"hash"]];
    [query whereKey:@"user" equalTo:user];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        // If there was an error, log it, and move on
        if(error) {
            NSLog(@"Error saving like: %@ %@", error, [error userInfo]);
            return;
        }
        
        if([objects count]) {
            // If we find one, then we delete it
            PFObject *like = [objects objectAtIndex:0];
            [like deleteInBackground];
            NSDictionary *resp = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"deleted", @"action",
                                  nil];
            callback(resp);
        } else {
            // Otherwise, we create one
            PFObject *like = [PFObject objectWithClassName:@"Like"];
            [like setObject:user forKey:@"user"];
            [like setObject:[image objectForKey:@"hash"] forKey:@"hash"];
            [like saveInBackground];
            NSDictionary *resp = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"created", @"action",
                                  nil];
            callback(resp);
        }
    }];
}

- (void)likeSummaryTappedForImage:(NSDictionary *)image
{
    // Open up the like summary screen
    LikeSummaryController *likeSummary = [[[LikeSummaryController alloc] init] autorelease];
    likeSummary.image = image;
    [ClutchView prepareForAnimation:likeSummary success:^{
        [self.navigationController pushViewController:likeSummary animated:YES];
    }];
}

- (void)commentTappedForImage:(NSDictionary *)image callback:(void(^)(id))callback
{
    // If there's no logged-in user, then we shouldn't do anything
    PFUser *user = [self ensureUser];
    if(!user) {
        return;
    }
    
    // Adding a new comment counts as a "significant event" in my eyes
    [Appirater userDidSignificantEvent:YES];
    
    CommentController *commentController = [[CommentController alloc] init];
    commentController.callbackBlock = callback;
    commentController.image = image;
    [self presentViewController:commentController animated:YES completion:^{
        [commentController.textView becomeFirstResponder];
        [commentController release];
    }];
}

- (void)moreTappedForImage:(NSDictionary *)image
{
    // First we show the loading view
    [self.clutchView.loadingView show:nil];
    
    // We construct the URL to the full-sized image
    NSString *url = [NSString stringWithFormat:@"http://i.imgur.com/%@%@",
                     [image objectForKey:@"hash"],
                     [image objectForKey:@"ext"]];
    
    // Now we download the full-sized image
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    AFHTTPRequestOperation *operation = [[[AFHTTPRequestOperation alloc] initWithRequest:request] autorelease];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation , id responseObject) {
        // If loading the image succeeded, we shut down the loading view and pop up a sharing dialog
        [self.clutchView.loadingView hide];
        UIImage *img = [UIImage imageWithData:operation.responseData];
        SHKItem *item = [SHKItem image:img title:[image objectForKey:@"title"]];
        SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
        [actionSheet showFromTabBar:self.navigationController.tabBarController.tabBar];
    } failure:^(AFHTTPRequestOperation *operation , NSError *error) {
        // If downloading the image failed, then we pop up an alert dialog
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not share" 
                                                        message:@"Sorry, there was an error preparing the image to be shared. Please try again." 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }];
    NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
    [queue addOperation:operation];
}

- (void)imagePopup:(NSDictionary *)image
{
    // If the user clicked on an image, we show a nice scrollable image popup
    NSString *url = [NSString stringWithFormat:@"http://i.imgur.com/%@%@",
                     [image objectForKey:@"hash"],
                     [image objectForKey:@"ext"]];
    
    EGOPhotoViewController *photoController = [[EGOPhotoViewController alloc] initWithImageURL:[NSURL URLWithString:url]];
    [self.navigationController pushViewController:photoController animated:YES];
    
    [photoController release];
}

#pragma mark - ClutchViewDelegate

- (void)clutchView:(ClutchView *)clutchView methodCalled:(NSString *)method withParams:(NSDictionary *)params callback:(void(^)(id))callback
{
    // This is where we inspect the method called and handle callbacks
    if([method isEqualToString:@"getInitialData"]) {
        PFUser *user = [PFUser currentUser];
        callback([NSDictionary dictionaryWithObjectsAndKeys:
                  self.image, @"image",
                  user ? [self getUserData:user] : [NSNull null], @"user",
                  nil]);
    } else if([method isEqualToString:@"likeTapped"]) {
        [self likeTappedForImage:params callback:callback];
    } else if([method isEqualToString:@"likeSummaryTapped"]) {
        [self likeSummaryTappedForImage:params];
    } else if([method isEqualToString:@"commentTapped"]) {
        [self commentTappedForImage:params callback:callback];
    } else if([method isEqualToString:@"moreTapped"]) {
        [self moreTappedForImage:params];
    } else if([method isEqualToString:@"imagePopup"]) {
        [self imagePopup:params];
    }
}

#pragma mark - View lifecycle

- (void)loadView
{
    self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bkg.png"]];
    
    // Set up the Clutch view
    self.clutchView = [[ClutchView alloc] initWithFrame:CGRectMake(0, 0, 320, 411)
                                                andSlug:@"imagedetail"];
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
