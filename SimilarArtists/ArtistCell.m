//
//  ArtistCell.m
//  SimilarArtists
//
//  Created by Jonathan Crossley on 9/2/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MGSwipeTableCell/MGSwipeButton.h>
#import <SpinKit/RTSpinKitView.h>
#import <libextobjc/EXTScope.h>
#import "ArtistCell.h"
#import "UIColor+HexColors.h"

@interface ArtistCell ()
@property RTSpinKitView *progressView;
@property UIImageView *backgroundImageView;
@end

@implementation ArtistCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // create a label that renders the artist name
        _label = [[UITextField alloc] initWithFrame:CGRectNull];
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont boldSystemFontOfSize:16.0f];
        _label.backgroundColor = [UIColor clearColor];
        _label.delegate = self;
        _label.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
        [self.contentView addSubview:_label];
        
        // create background image view
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectNull];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.backgroundView = _backgroundImageView;
        
        // add SpinKit view
        _progressView = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWave];
        [self.contentView addSubview:_progressView];
        
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
    _progressView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _progressView.color = [UIColor whiteColor];
}

#pragma mark - setter
-(void)setArtist:(Artist *)artist {
    _artist = artist;
    _label.text = artist.name;
    _label.textColor = artist.liked.intValue ==  1 ? [UIColor myLightGreenColor]
                     : artist.liked.intValue == -1 ? [UIColor myRedColor]
                     : [UIColor whiteColor];
    
    // clear cached image
    UIImageView *backgroundImage = (UIImageView*)self.backgroundView;
    backgroundImage.image = nil;
    
    if (artist.images.count > 0) {
        [self setBackgroundImageForArtist:artist];
    }
}

typedef void (^ImageSuccess)(NSURLRequest*, NSHTTPURLResponse*, UIImage*);
typedef void (^ImageError)(NSURLRequest*, NSHTTPURLResponse*, NSError*);

-(void)setBackgroundImageForArtist:(Artist*)artist {
    [_progressView startAnimating];
    
    NSURL *imageUrl = [NSURL URLWithString:[artist.images[0] text]]; //todo!
    
    @weakify(self)
    ImageSuccess success = ^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        @strongify(self)
        [self.progressView stopAnimating];
        [self.backgroundImageView setImage:image];
    };
    ImageError failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        @strongify(self)
        [self.progressView stopAnimating];
    };
    
    [self.backgroundImageView setImageWithURLRequest:[NSURLRequest requestWithURL:imageUrl]
                                    placeholderImage:nil
                                             success:success
                                             failure:failure];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return NO; //todo!
}

#pragma mark - MGTableCell


@end
