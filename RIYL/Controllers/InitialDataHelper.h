#import <Foundation/Foundation.h>

@interface InitialDataHelper : NSObject

+ (InitialDataHelper*) sharedInstance;

- (BOOL)hasPrefilledArtists;
- (void)initializeData;

@end
