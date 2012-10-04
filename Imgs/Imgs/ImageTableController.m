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

#import "ImageTableController.h"
#import "LoginOptionController.h"
#import "CommentController.h"
#import "ImageDetailController.h"
#import "LikeSummaryController.h"
#import "EGOPhotoGlobal.h"
#import "SHK.h"
#import "Appirater.h"

@implementation ImageTableController

@synthesize clutchView = _clutchView;
@synthesize kind = _kind;
@synthesize displayType = _displayType;
@synthesize refreshHeaderView = _refreshHeaderView;
@synthesize refreshHider = _refreshHider;
@synthesize dateLastUpdated = _dateLastUpdated;
@synthesize reloading = _reloading;

- (ImageTableController *)initWithKind:(NSString *)kind
{
    self = [super init];
    if (self) {
        self.kind = kind;
        
        // Defaults to "detail"
        self.displayType = @"detail";
        
        // Set the title and the tab bar image
        self.title = [NSString stringWithFormat:@"%@ Images", [self.kind capitalizedString]];
        self.tabBarItem.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-icon.png", self.kind]];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
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
        nav.navigationBar.translucent = YES;
        [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"top-bar-blank.png"]
                                forBarMetrics:UIBarMetricsDefault];
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

- (void)getJSON:(NSString *)url
        success:(void(^)(id))successBlock_ 
        failure:(void(^)(AFHTTPRequestOperation *))failureBlock_
{
    // Fetches a list of images from Imgur's API, then annotates it with like and comment data from Parse.
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    [request setValue:[NSString stringWithFormat:@"application/json; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    // Put the request in an operation
    AFHTTPRequestOperation *operation = [[[AFHTTPRequestOperation alloc] initWithRequest:request] autorelease];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation , id responseObject) {
        NSDictionary *resp = [operation.responseString objectFromJSONString];
        if(resp == nil || [[NSNull null] isEqual:resp]) {
            // If the request failed, call the failure block with the operation as an argument
            failureBlock_(operation);
        } else {
            /* Now we have the images in 'resp', we need to do a query for all the likes on them. */
            
            // First we need to make a deep mutable copy of the image gallery list
            NSArray *origGallery = [resp objectForKey:@"data"];
            NSMutableArray *gallery = [NSMutableArray arrayWithCapacity:[origGallery count]];
            for(int i = 0; i < [origGallery count]; ++i) {
                NSDictionary *image = [[origGallery objectAtIndex:i] mutableCopy];
                [gallery addObject:image];
                [image release];
            }
            
            // Get all of the hashes from the list of images
            NSMutableArray *images = [NSMutableArray arrayWithCapacity:[gallery count]];
            for(int i = 0; i < [gallery count]; ++i) {
                [images addObject:[[gallery objectAtIndex:i] objectForKey:@"hash"]];
            }
            
            NSMutableDictionary *likes = [NSMutableDictionary dictionaryWithCapacity:[gallery count]];
            NSMutableDictionary *comments = [NSMutableDictionary dictionaryWithCapacity:[gallery count]];
            
            // This code block will be called asynchronously when both of the next two operations are done.
            // The reason it's a block is because we need access to all of these local variables, but we
            // don't want to have to copy and paste the code twice.
            void (^completion) (void) = ^{
                /* Now we have all of the likes sorted into who liked it and who commented on it,
                 we now want to annotate the actual image dictionaries with this data */
                for(int i = 0; i < [gallery count]; ++i) {
                    NSMutableDictionary *image = [gallery objectAtIndex:i];
                    NSMutableArray *imageLikes = [likes objectForKey:[image objectForKey:@"hash"]];
                    if(!imageLikes) {
                        imageLikes = [NSMutableArray array];
                    }
                    [image setObject:imageLikes forKey:@"likes"];
                    NSMutableArray *imageComments = [comments objectForKey:[image objectForKey:@"hash"]];
                    if(!imageComments) {
                        imageComments = [NSMutableArray array];
                    }
                    [image setObject:imageComments forKey:@"comments"];
                }
                
                // WOOHOO! Pass this annoated image gallery back to the javascript layer.
                successBlock_([NSDictionary dictionaryWithObjectsAndKeys:
                               gallery, @"gallery",
                               nil]);
            };
            
            // This counter starts at zero, but once it hits 2, then the above completion block should be called.
            __block int queryResponse = 0;
            
            // Query for all of the likes on the images in the stream
            PFQuery *likeQuery = [PFQuery queryWithClassName:@"Like"];
            likeQuery.limit = [NSNumber numberWithInt:1000];
            [likeQuery whereKey:@"hash" containedIn:images];
            [likeQuery includeKey:@"user"];
            [likeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if(error) {
                    // Even if we error, we still want to set an empty array into the image object
                    for(int i = 0; i < [objects count]; ++i) {
                        PFObject *obj = [objects objectAtIndex:i];
                        [likes setObject:[NSMutableArray array] forKey:[obj objectForKey:@"hash"]];
                    }
                } else {
                    /* Now we have all the likes, we need to convert them into a dictionary
                     mapping the image hash to the users who like it. */
                    for(int i = 0; i < [objects count]; ++i) {
                        PFObject *obj = [objects objectAtIndex:i];
                        NSMutableArray *imageLikes = [likes objectForKey:[obj objectForKey:@"hash"]];
                        if(!imageLikes) {
                            imageLikes = [NSMutableArray array];
                            [likes setObject:imageLikes forKey:[obj objectForKey:@"hash"]];
                        }
                        [imageLikes addObject:[self getUserData:[obj objectForKey:@"user"]]];
                    }
                }
                if(++queryResponse == 2) {
                    completion();
                }
            }];
            
            // Query for all of comments for this same set of images
            PFQuery *commentQuery = [PFQuery queryWithClassName:@"Comment"];
            commentQuery.limit = [NSNumber numberWithInt:1000];
            [commentQuery orderByAscending:@"createdAt"];
            [commentQuery whereKey:@"hash" containedIn:images];
            [commentQuery includeKey:@"user"];
            [commentQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if(error) {
                    // Even if we error, we still want to set an empty array into the image object
                    for(int i = 0; i < [objects count]; ++i) {
                        PFObject *obj = [objects objectAtIndex:i];
                        [comments setObject:[NSMutableArray array] forKey:[obj objectForKey:@"hash"]];
                    }
                } else {
                    /* Now we have all the comments, we need to convert them into a dictionary
                     mapping the image hash to the users who like it. */
                    for(int i = 0; i < [objects count]; ++i) {
                        PFObject *obj = [objects objectAtIndex:i];
                        NSMutableArray *imageComments = [comments objectForKey:[obj objectForKey:@"hash"]];
                        if(!imageComments) {
                            imageComments = [NSMutableArray array];
                            [comments setObject:imageComments forKey:[obj objectForKey:@"hash"]];
                        }
                        
                        NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [self getUserData:[obj objectForKey:@"user"]], @"user",
                                              [obj objectForKey:@"text"], @"text",
                                              nil];
                        [imageComments addObject:item];
                    }
                }
                if(++queryResponse == 2) {
                    completion();
                }
            }];
            
        }
    } failure:^(AFHTTPRequestOperation *operation , NSError *error) {
        // If the request failed, call the failure block with the operation as an argument
        failureBlock_(operation);
    }];
    
    // Add the operation to an NSOperationQueue
    NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
    [queue addOperation:operation];
}

#pragma mark - ClutchViewDelegate

- (void)clutchView:(ClutchView *)clutchView
      methodCalled:(NSString *)method
        withParams:(NSDictionary *)params
          callback:(void(^)(id))callback
{
    // This is where we inspect the method called and handle callbacks
    if([method isEqualToString:@"imgurRequest"]) {
        [self getJSON:[params objectForKey:@"url"] success:^(id data) {
            callback([NSDictionary dictionaryWithObjectsAndKeys:data, @"data", nil]);
        } failure:^(AFHTTPRequestOperation *operation) {
            callback([NSDictionary dictionaryWithObjectsAndKeys:
                      [NSNumber numberWithBool:TRUE], @"error",
                      nil]);
        }];
    } else if([method isEqualToString:@"clutch.loading.end"]) {
        [self doneLoadingTableViewData];
    } else if([method isEqualToString:@"getInitialData"]) {
        PFUser *user = [PFUser currentUser];
        callback([NSDictionary dictionaryWithObjectsAndKeys:
                  self.kind, @"kind",
                  self.displayType, @"displayType",
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
    } else if([method isEqualToString:@"imageThumbnailTapped"]) {
        ImageDetailController *imageDetail = [[[ImageDetailController alloc] init] autorelease];
        imageDetail.image = params;
        [ClutchView prepareForAnimation:imageDetail success:^{
            [self.navigationController pushViewController:imageDetail animated:YES];
        }];
    } else if([method isEqualToString:@"imagePopup"]) {
        [self imagePopup:params];
    }
}

#pragma mark - View lifecycle

- (void)loadView
{
    self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bkg.png"]];
    
    // Make the navigation bar translucent and have the right background
    self.navigationController.navigationBar.translucent = YES;
    
    // Add the List/Thumb picker and set up the delegate so that we can respond to the button clicks
    UISegmentedControl *seg = [[[UISegmentedControl alloc]
                                initWithItems:[NSArray arrayWithObjects:@"List", @"Thumb", nil]] autorelease];
    seg.opaque = FALSE;
    seg.tintColor = [UIColor darkGrayColor];
    seg.selectedSegmentIndex = 0;
    [seg setSegmentedControlStyle:UISegmentedControlStyleBar];
    [seg addTarget:self action:@selector(displayChanged:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = seg;
    
    // Set up the Clutch view
    self.clutchView = [[ClutchView alloc] initWithFrame:CGRectMake(0, 0, 320, 411)
                                                andSlug:@"imagetable"];
    [self.clutchView release];
    self.clutchView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(44, 0, 0, 0);
    self.clutchView.delegate = self;
    self.clutchView.scrollDelegate = self;
    [self.view addSubview:self.clutchView];
    
    // Set the date last updated to now on the first load
    self.dateLastUpdated = [NSDate date];
    
    // Initialize the pull-to-refresh implementation
    EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -324, 320, 368)];
    view.delegate = self;
    [self.view addSubview:view];
    self.refreshHeaderView = view;
    [view release];
    [self.refreshHeaderView refreshLastUpdatedDate];
    
    // Initialize our UIViw trick to make sure pull-to-refresh isn't shown behind our nice translucent header
    self.refreshHider = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [self.refreshHider release];
    self.refreshHider.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bkg.png"]];
    [self.view addSubview:self.refreshHider];
    
    // Add a login button if the user is not logged in
    [self setupLoginButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.clutchView = nil;
    self.kind = nil;
    self.displayType = nil;
    self.refreshHeaderView = nil;
    self.refreshHider = nil;
    self.dateLastUpdated = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top-bar.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.clutchView viewDidAppear:animated];
    
    // If there's a user, call setUser on the Clutch side of things
    PFUser *user = [PFUser currentUser];
    if(user) {
        [self.clutchView callMethod:@"setUser" withParams:[self getUserData:user]];
    }
    
    // Add a login button if the user is not logged in, or remove it if they just logged in
    [self setupLoginButton];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.clutchView viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Scroll view

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
    // This slides the pull-to-refresh view into the proper location
    self.refreshHeaderView.frame = CGRectMake(self.refreshHeaderView.frame.origin.x,
                                              -324.0f - scrollView.contentOffset.y,
                                              self.refreshHeaderView.frame.size.width,
                                              self.refreshHeaderView.frame.size.height);
    
    // This is our trick for making sure pull-to-refresh isn't shown behind our nice translucent header.
    // That is, if the user scrolls down beyond the bounds so that it pulls down the pull-to-refresh, then
    // have this view stay right below the header.  Otherwise if the user scrolls up, have this view
    // scroll up accordingly.
    if(scrollView.contentOffset.y > 0) {
        self.refreshHider.frame = CGRectMake(self.refreshHider.frame.origin.x,
                                             0 - scrollView.contentOffset.y,
                                             self.refreshHider.frame.size.width,
                                             self.refreshHider.frame.size.height);
    } else {
        self.refreshHider.frame = CGRectMake(self.refreshHider.frame.origin.x,
                                             0,
                                             self.refreshHider.frame.size.width,
                                             self.refreshHider.frame.size.height);
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - Pull to Refresh

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self.clutchView.webView reload];
    self.reloading = TRUE;
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
	return self.reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
	return self.dateLastUpdated;
}

- (void)doneLoadingTableViewData
{
    self.reloading = FALSE;
    self.dateLastUpdated = [NSDate date];
    [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.clutchView.scrollView];
}

#pragma mark - Segmented Control

- (void)displayChanged:(UISegmentedControl *)segmentedControl
{
    [self.clutchView.loadingView show:nil];
	int sortOrder = [segmentedControl selectedSegmentIndex];
    if(sortOrder == 0) {
        self.displayType = @"detail";
    } else {
        self.displayType = @"thumb";
    }
    [self.clutchView.webView reload];
}

@end
