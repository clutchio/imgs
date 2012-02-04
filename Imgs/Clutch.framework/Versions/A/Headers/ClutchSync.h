//
//  ClutchSync.h
//  Clutch
//
//  Created by Eric Florenzano on 10/18/11.
//  Copyright (c) 2011 Boilerplate Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Clutch/ClutchAPIClient.h>
#import <Clutch/ClutchConf.h>
#import <Clutch/ClutchStats.h>

@interface ClutchSync : NSObject {
    NSString *_appKey;
    NSString *_cursor;
    BOOL _shouldWatchForChanges;
    BOOL _pendingReload;
}

@property (nonatomic, retain) NSString *appKey;
@property (nonatomic, retain) NSString *cursor;
@property (nonatomic, assign) BOOL shouldWatchForChanges;
@property (assign) BOOL pendingReload;

+ (ClutchSync *)sharedClient:(NSString *)appKey;
- (void)watchForChanges;
- (void)sync;
- (void)background;
- (void)foreground;
- (NSString *)getCacheDir;

@end
