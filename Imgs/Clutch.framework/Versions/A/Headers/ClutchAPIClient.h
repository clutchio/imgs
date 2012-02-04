//
//  SHAPIClient.h
//  Clutch
//
//  Created by Eric Florenzano on 10/18/11.
//  Copyright (c) 2011 Boilerplate Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Clutch/ClutchConf.h>
#import <Clutch/AFNetworking.h>

extern NSString * const kClutchBaseURLString;
extern NSString * const kClutchAPIVersion;

@interface ClutchAPIClient : AFHTTPClient {
    NSString *_appKey;
}

@property (nonatomic, retain) NSString *appKey;

+ (ClutchAPIClient *)sharedClient:(NSString *)appKey;
- (void)downloadFile:(NSString *)fileName
             version:(NSString *)version
             success:(void(^)(NSData *))successBlock_
             failure:(void(^)(NSData *, NSError *))failureBlock_;
- (void)callMethod:(NSString *)methodName
        withParams:(NSDictionary *)params
           success:(void(^)(id))successBlock_ 
           failure:(void(^)(NSData *, NSError *))failureBlock_;

@end
