//
//  Artist.h
//  SimilarArtists
//
//  Created by Jonathan Crossley on 9/6/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Artist, Image;

@interface Artist : NSManagedObject

@property (nonatomic, retain) NSString *bio;
@property (nonatomic, retain) NSString *mbid;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSNumber *liked;
@property (nonatomic, retain) NSOrderedSet *images;
@property (nonatomic, retain) NSOrderedSet *similarArtists;
@property (nonatomic, retain) Artist *similarParent;

@end

@interface Artist (CoreDataGeneratedAccessors)

- (void)insertObject:(Image *)value inImagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromImagesAtIndex:(NSUInteger)idx;
- (void)insertImages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeImagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInImagesAtIndex:(NSUInteger)idx withObject:(Image *)value;
- (void)replaceImagesAtIndexes:(NSIndexSet *)indexes withImages:(NSArray *)values;
- (void)addImagesObject:(Image *)value;
- (void)removeImagesObject:(Image *)value;
- (void)addImages:(NSOrderedSet *)values;
- (void)removeImages:(NSOrderedSet *)values;
- (void)insertObject:(Artist *)value inSimilarArtistsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSimilarArtistsAtIndex:(NSUInteger)idx;
- (void)insertSimilarArtists:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeSimilarArtistsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInSimilarArtistsAtIndex:(NSUInteger)idx withObject:(Artist *)value;
- (void)replaceSimilarArtistsAtIndexes:(NSIndexSet *)indexes withSimilarArtists:(NSArray *)values;
- (void)addSimilarArtistsObject:(Artist *)value;
- (void)removeSimilarArtistsObject:(Artist *)value;
- (void)addSimilarArtists:(NSOrderedSet *)values;
- (void)removeSimilarArtists:(NSOrderedSet *)values;

@end
