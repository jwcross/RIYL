//
//  ArtistCell.m
//  SimilarArtists
//
//  Created by Jonathan Crossley on 9/2/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "ArtistCell.h"

@implementation ArtistCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // create a label that renders the artist name
        _label = [[UITextField alloc] initWithFrame:CGRectNull];
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont boldSystemFontOfSize:16.0f];
        _label.backgroundColor = [UIColor clearColor];
        _label.delegate = self;
        _label.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
        [self addSubview:_label];
        
        // create background image view
        self.backgroundView = [[UIImageView alloc] initWithFrame:CGRectNull];
        [self.backgroundView setContentMode:UIViewContentModeScaleAspectFill];
        
        // clear background
        self.backgroundColor = [UIColor clearColor];
        
        // clip to bounds for the image view
        self.clipsToBounds = YES;
        self.backgroundView.clipsToBounds = YES;
        
        // remove the default highlight for selected cells
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

const float LABEL_MARGIN = 12.0f;

-(void)layoutSubviews {
    [super layoutSubviews];
    _label.frame = CGRectMake(LABEL_MARGIN, 0, self.bounds.size.width - LABEL_MARGIN,
                              self.bounds.size.height - LABEL_MARGIN);
}

#pragma mark - setter
-(void)setArtist:(Artist *)artist {
    _artist = artist;
    _label.text = artist.name;
    
    // clear cached image
    UIImageView *backgroundImage = (UIImageView*)self.backgroundView;
    backgroundImage.image = nil;
    // set background image
    if (artist.images.count > 0) {
        NSURL *imageUrl = [NSURL URLWithString:[artist.images[0] text]]; //todo!
        [backgroundImage setImageWithURL:imageUrl];
    }
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return NO; //todo!
}

@end
