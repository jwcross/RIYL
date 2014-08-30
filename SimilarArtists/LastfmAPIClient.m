//
//  LastfmAPIClient.m
//  SimilarArtists
//
//  Created by Jonathan Crossley on 8/29/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import "LastfmAPIClient.h"

NSString * const kLastfmAPIKey = @"92bfae0198f438e318ef4917ed38bd41";
NSString * const kLastfmBaseURL = @"http://ws.audioscrobbler.com/2.0/";

@implementation LastfmAPIClient

+ (LastfmAPIClient *)sharedClient {
    static LastfmAPIClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kLastfmBaseURL]];
    });
    return _sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    return self;
}

- (void)getSimilarArtistsForArtist:(NSString *)artistString
                             limit:(NSInteger)limit
                       autocorrect:(BOOL)autocorrect
                           success:(void (^)(NSURLSessionDataTask *, id))success
                           failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSLog(@"getSimilarArtistsForArtist");
    
}

@end
