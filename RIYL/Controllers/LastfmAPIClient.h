#import <AFNetworking/AFNetworking.h>

@interface LastfmAPIClient : AFHTTPSessionManager

+ (LastfmAPIClient*)sharedClient;

// Get similar artists
- (void)getSimilarArtistsForArtist:(NSString *)artistString
                             limit:(NSInteger)limit
                       autocorrect:(BOOL)autocorrect
                           success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                           failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;

// Get artist info
- (void)getInfoForArtist:(NSString *)artistString
             autocorrect:(BOOL)autocorrect
                 success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                 failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;
@end
