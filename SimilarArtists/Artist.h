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
@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSOrderedSet *images;

@end

@interface Artist (CoreDataGeneratedAccessors)

- (void)insertObject:(NSManagedObject *)value inImagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromImageAtIndex:(NSUInteger)idx;
- (void)insertImages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeImagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInImagesAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceImagesAtIndexes:(NSIndexSet *)indexes withImages:(NSArray *)values;
- (void)addImagesObject:(NSManagedObject *)value;
- (void)removeImagesObject:(NSManagedObject *)value;
- (void)addImages:(NSOrderedSet *)values;
- (void)removeImages:(NSOrderedSet *)values;

@end
