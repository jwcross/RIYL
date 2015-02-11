//
//  SpotifyAPIClient.h
//  SimilarArtists
//
//  Created by Jonathan Crossley on 8/29/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface SpotifyAPIClient : AFHTTPSessionManager

typedef void (^SuccessCallback)(NSURLSessionDataTask *task, id response);
typedef void (^ErrorCallback)(NSURLSessionDataTask *task, NSError *error);

+ (SpotifyAPIClient*)sharedClient;

-(void)getArtistByName:(NSString *)artistName
               success:(SuccessCallback)success
               failure:(ErrorCallback)failure;
    
@end
