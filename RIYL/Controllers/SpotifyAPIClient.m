#import "SpotifyAPIClient.h"

@implementation SpotifyAPIClient

NSString * const kSpotifyBaseURL = @"https://api.spotify.com";

+ (SpotifyAPIClient *)sharedClient {
    static SpotifyAPIClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kSpotifyBaseURL]];
    });
    return _sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    
    self = [super initWithBaseURL:url];
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return self;
}

-(void)getArtistByName:(NSString *)artistName
               success:(SuccessCallback)success
               failure:(ErrorCallback)failure {
    
    NSString *searchUrl = [NSString stringWithFormat:@"%@/v1/search", kSpotifyBaseURL];
    NSString *query = [artistName stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSDictionary *params = @{ @"q":query, @"type":@"artist" };
    
    [self GET:searchUrl parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Success -- %@", responseObject);
        if (success) {
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Failed to fetch %@ from Spotify", artistName);
        if (failure) {
            failure(task, error);
        }
    }];
}

@end
