//
//  Image.h
//  SimilarArtists
//
//  Created by Jonathan Crossley on 9/6/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Artist;

@interface Image : NSManagedObject

@property (nonatomic, retain) NSString * size;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Artist *artist;

+(Image*)createEntityWithUrl:(NSString*)url;

@end
