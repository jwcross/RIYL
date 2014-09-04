//
//  ArtistCollectionViewCell.m
//  SimilarArtists
//
//  Created by Jonathan Crossley on 9/3/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import "ArtistCollectionViewCell.h"

@implementation ArtistCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // create a label that renders the artist name.
        _label = [[UILabel alloc] initWithFrame:CGRectNull];
        _label.textColor = [UIColor blackColor];
        _label.font = [UIFont boldSystemFontOfSize:16.0f];
        _label.backgroundColor = [UIColor clearColor];
        [self addSubview:_label];
        
        [self setNeedsLayout];
    }
    return self;
}

const float LABEL_MARGIN_CV = 12.0f;

-(void)layoutSubviews {
    [super layoutSubviews];
    _label.frame = CGRectMake(LABEL_MARGIN_CV, 0, self.bounds.size.width - LABEL_MARGIN_CV,
                              self.bounds.size.height - LABEL_MARGIN_CV);
}

@end
