//
//  LastfmAPIClient.h
//  SimilarArtists
//
//  Created by Jonathan Crossley on 8/29/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

extern NSString * const kLastfmAPIKey;
extern NSString * const kLastfmBaseURLString;

@interface LastfmAPIClient : AFHTTPSessionManager

+ (LastfmAPIClient*)sharedClient;

- (void)getSimilarArtistsForArtist:(NSString *)artistString
                             limit:(NSInteger)limit
                       autocorrect:(BOOL)autocorrect
                           success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                           failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;

@end
