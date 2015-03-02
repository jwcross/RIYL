#import <AFNetworking/AFNetworking.h>

@interface SpotifyAPIClient : AFHTTPSessionManager

typedef void (^SuccessCallback)(NSURLSessionDataTask *task, id response);
typedef void (^ErrorCallback)(NSURLSessionDataTask *task, NSError *error);

+ (SpotifyAPIClient*)sharedClient;

-(void)getArtistByName:(NSString *)artistName
               success:(SuccessCallback)success
               failure:(ErrorCallback)failure;
    
@end
