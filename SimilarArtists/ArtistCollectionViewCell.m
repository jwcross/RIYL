//
//  ArtistCollectionViewCell.m
//  SimilarArtists
//
//  Created by Jonathan Crossley on 9/3/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import "ArtistCollectionViewCell.h"

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
    _label.textColor = [UIColor whiteColor];
    _label.font = [UIFont boldSystemFontOfSize:12.0f];
    _label.numberOfLines = 0;
    [_label sizeToFit];
}

@end
