//
//  Artist.h
//  SimilarArtists
//
//  Created by Jonathan Crossley on 8/30/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Image;

@interface Artist : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * mbid;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSSet *images;
@end

@interface Artist (CoreDataGeneratedAccessors)

- (void)addImage:(Image *)value;
- (void)removeImage:(Image *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
