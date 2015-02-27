//
//  InitialDataHelper.h
//  SimilarArtists
//
//  Created by Jonathan Crossley on 2/10/15.
//  Copyright (c) 2015 CCS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InitialDataHelper : NSObject

+ (InitialDataHelper*) sharedInstance;

- (BOOL)hasPrefilledArtists;
- (void)initializeData;

@end
