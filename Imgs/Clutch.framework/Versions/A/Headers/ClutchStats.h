//
//  ClutchStats.h
//  Clutch
//
//  Created by Eric Florenzano on 12/1/11.
//  Copyright (c) 2011 Made with Lasers, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Clutch/ClutchUtils.h>
#import "/usr/include/sqlite3.h"

@interface ClutchStats : NSObject {
    sqlite3 *db;
    NSString *_databasePath;
}

+ (ClutchStats *)sharedClient;
- (void)ensureDatabaseCreated;
- (void)log:(NSString *)action withData:(NSDictionary *)data;
- (void)log:(NSString *)action;
- (NSArray *)getLogs;
- (void)deleteLogs:(NSTimeInterval)beforeOrEqualTo;

@property (nonatomic, retain) NSString *databasePath;

@end
