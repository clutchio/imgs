//
//  AppDelegate.m
//  Imgs
//
//  Created by Eric Florenzano on 1/17/12.
//  Copyright (c) 2012 Boilerplate Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "ImageTableController.h"
#import "MoreController.h"
#import "SHKFacebook.h"
#import "Appirater.h"
#import <Parse/Parse.h>

static NSString *kClutchAppId = @"7e065a47-90f1-4e17-84a5-8197583dda83";
static NSString *kClutchTunnelURL = @"http://127.0.0.1:41675/";
static NSString *kClutchRpcURL = @"http://127.0.0.1:41674/";

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    // Initialize all of our controllers
    ImageTableController *hot = [[[ImageTableController alloc] initWithKind:@"hot"] autorelease];
    ImageTableController *new = [[[ImageTableController alloc] initWithKind:@"new"] autorelease];
    ImageTableController *top = [[[ImageTableController alloc] initWithKind:@"top"] autorelease];
    MoreController *more = [[[MoreController alloc] init] autorelease];
    
    // Put all of the controllers into navigation controllers
    UINavigationController *hotNav = [[[UINavigationController alloc] initWithRootViewController:hot] autorelease];
    UINavigationController *newNav = [[[UINavigationController alloc] initWithRootViewController:new] autorelease];
    UINavigationController *topNav = [[[UINavigationController alloc] initWithRootViewController:top] autorelease];
    UINavigationController *moreNav = [[[UINavigationController alloc] initWithRootViewController:more] autorelease];
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:hotNav, newNav, topNav, moreNav, nil];
    self.window.rootViewController = self.tabBarController;

    // Synchronize with the Clutch servers
    [[ClutchSync sharedClientForKey:kClutchAppId tunnelURL:kClutchTunnelURL rpcURL:kClutchRpcURL] sync];
    
    // Log the device identifier
    [ClutchView logDeviceIdentifier];

    // Use our nice background image for the navigation bar and make the back button match it
    [[UIBarButtonItem appearance] setTintColor:[UIColor blackColor]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"top-bar.png"]
                                       forBarMetrics:UIBarMetricsDefault];
    
    [ClutchView prepareForDisplay:hot];
    [ClutchView prepareForDisplay:new];
    [ClutchView prepareForDisplay:top];
    [ClutchView prepareForDisplay:more];
    
    // Initialize Parse
    [Parse setApplicationId:@"8SD1gzkPlWeGIduzcwqDBIAhLUzzrbtNGdWPqbYi" 
                  clientKey:@"zwpVzWtaHpHKNaoU0Wd42UIPTsmsb3EZqcwhKUiG"];
    [Parse setFacebookApplicationId:@"111163632339814"];
    
    // Integrate with Appirater to ask people to rate the app
    [Appirater appLaunched:YES];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [[ClutchSync sharedClientForKey:kClutchAppId tunnelURL:kClutchTunnelURL rpcURL:kClutchRpcURL] background];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    [[ClutchSync sharedClientForKey:kClutchAppId tunnelURL:kClutchTunnelURL rpcURL:kClutchRpcURL] foreground];
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    [SHKFacebook handleOpenURL:url];
    return [[PFUser facebook] handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [SHKFacebook handleOpenURL:url];
    return [[PFUser facebook] handleOpenURL:url]; 
}

@end
