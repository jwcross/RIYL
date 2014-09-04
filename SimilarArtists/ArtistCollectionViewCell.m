//
//  ArtistCollectionViewCell.m
//  SimilarArtists
//
//  Created by Jonathan Crossley on 9/3/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import "ArtistCollectionViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface ArtistCollectionViewCell ()

@property (nonatomic, strong) IBOutlet UIImageView *image;

@end

@implementation ArtistCollectionViewCell

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // subviews not yet available
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    // style subviews
    self.backgroundColor = [UIColor grayColor];
    _label.font = [UIFont boldSystemFontOfSize:12.0f];
    _label.numberOfLines = 0;
    _label.textColor = [UIColor whiteColor];
    _label.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.8];
    [_label sizeToFit];
}

#pragma mark - setter
-(void)setArtist:(Artist *)artist {
    _artist = artist;
    _label.text = artist.name;
    // set background image
    if (artist.images.count > 0) {
        NSURL *imageUrl = [NSURL URLWithString:[artist.images[0] text]]; //todo?
        [self.image setImageWithURL:imageUrl];
    } else {
        [self.image setImage:nil];
    }
}

@end
