//
//  Artist.m
//  SimilarArtists
//
//  Created by Jonathan Crossley on 8/30/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import "Artist.h"
#import "Image.h"

@implementation Artist

@dynamic name;
@dynamic mbid;
@dynamic url;
@dynamic images;

-(void)addImagesObject:(NSManagedObject *)value {
    // Create a mutable set with the existing objects, add the new object, update relationship
    NSMutableOrderedSet *images = [[NSMutableOrderedSet alloc] initWithOrderedSet:self.images];
    [images addObject:value];
    self.images = images;
}

@end
