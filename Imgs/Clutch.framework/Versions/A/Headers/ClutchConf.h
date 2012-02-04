//
//  ClutchConf.h
//  Clutch
//
//  Created by Eric Florenzano on 10/23/11.
//  Copyright (c) 2011 Boilerplate Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClutchConf : NSObject

+ (void)setConf:(NSDictionary *)conf;
+ (NSString *)getClutchSubdir;
+ (NSDictionary *)conf;
+ (NSInteger)version;

@end
