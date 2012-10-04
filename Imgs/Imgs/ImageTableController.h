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

#import <UIKit/UIKit.h>
#import <Clutch/Clutch.h>
#import "EGORefreshTableHeaderView.h"
#import "JSONKit.h"
#import "AFNetworking.h"
#import <Parse/Parse.h>

@interface ImageTableController : UIViewController <ClutchViewDelegate, UIScrollViewDelegate, EGORefreshTableHeaderDelegate>

@property (nonatomic, retain) ClutchView *clutchView;
@property (nonatomic, retain) NSString *kind;
@property (nonatomic, retain) NSString *displayType;
@property (nonatomic, retain) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, retain) UIView *refreshHider;
@property (nonatomic, retain) NSDate *dateLastUpdated;
@property (nonatomic, assign) BOOL reloading;

- (ImageTableController *)initWithKind:(NSString *)kind;
- (void)doneLoadingTableViewData;
- (void)getJSON:(NSString *)url
        success:(void(^)(id))successBlock_ 
        failure:(void(^)(AFHTTPRequestOperation *))failureBlock_;

@end
