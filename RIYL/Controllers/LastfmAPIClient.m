#import "LastfmAPIClient.h"
#import "Keys.h"

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
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return self;
}

- (void)getSimilarArtistsForArtist:(NSString *)artistString
                             limit:(NSInteger)limit
                       autocorrect:(BOOL)autocorrect
                           success:(void (^)(NSURLSessionDataTask *, id))success
                           failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    [self GET:kLastfmBaseURL
   parameters:@{ @"method":@"artist.getSimilar",
                 @"format":@"json",
                 @"api_key":LASTFM_API_KEY,
                 @"artist":artistString,
                 @"autocorrect":(autocorrect? @1 : @0),
                 @"limit":@(limit)}
      success:^(NSURLSessionDataTask *task, id responseObject) {
          if (success) {
              success(task, responseObject);
          }
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          if (failure) {
              failure(task, error);
          }
      }];
}

-(void)getInfoForArtist:(NSString *)artistString
            autocorrect:(BOOL)autocorrect
                success:(void (^)(NSURLSessionDataTask *, id))success
                failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    [self GET:kLastfmBaseURL
   parameters:@{ @"method":@"artist.getInfo",
                 @"format":@"json",
                 @"api_key":LASTFM_API_KEY,
                 @"artist":artistString,
                 @"autocorrect":(autocorrect? @1: @0)}
      success:^(NSURLSessionDataTask *task, id responseObject) {
          if (success) {
              success(task, responseObject);
          }
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          if (failure) {
              failure(task, error);
          }
      }];
}

@end
