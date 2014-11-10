//
//  Artist.m
//  SimilarArtists
//
//  Created by Jonathan Crossley on 9/6/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import "Artist.h"
#import "Artist.h"
#import "Image.h"


@implementation Artist

@dynamic bio;
@dynamic mbid;
@dynamic name;
@dynamic url;
@dynamic liked;
@dynamic nowListening;
@dynamic images;
@dynamic similarArtists;
@dynamic similarParent;

-(void)addImagesObject:(NSManagedObject *)value {
    // Create a mutable set with the existing objects, add the new object, update relationship
    NSMutableOrderedSet *images = [[NSMutableOrderedSet alloc] initWithOrderedSet:self.images];
    [images addObject:value];
    self.images = images;
}

@end
