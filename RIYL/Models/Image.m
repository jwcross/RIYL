//
//  Image.m
//  SimilarArtists
//
//  Created by Jonathan Crossley on 9/6/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import "Image.h"
#import "Artist.h"


@implementation Image

@dynamic size;
@dynamic text;
@dynamic artist;

+(Image *)createEntityWithUrl:(NSString *)url {
    Image *image = [Image MR_createEntity];
    image.text = url;
    return image;
}

@end
