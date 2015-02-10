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
#import "ArtistCell.h"

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
    _label.textColor = artist.liked.intValue ==  1 ? [UIColor greenColor]
                     : artist.liked.intValue == -1 ? [UIColor redColor]
                     : [UIColor whiteColor];
    
    // clear cached image
    UIImageView *backgroundImage = (UIImageView*)self.backgroundView;
    backgroundImage.image = nil;
    
    if (artist.images.count > 0) {
        [self setBackgroundImageForArtist:artist];
    }
}

-(void)setBackgroundImageForArtist:(Artist*)artist {
    UIImageView *backgroundImage = (UIImageView*)self.backgroundView;
    [_progressView startAnimating];
    
    NSURL *imageUrl = [NSURL URLWithString:[artist.images[0] text]]; //todo!
    
    __weak ArtistCell *weakSelf = self;
    [backgroundImage setImageWithURLRequest:[NSURLRequest requestWithURL:imageUrl]
                           placeholderImage:nil
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                        NSLog(@"Success -- fetching image");
                                        __strong ArtistCell *strongSelf = weakSelf;
                                        [strongSelf.progressView stopAnimating];
                                        [strongSelf.backgroundImageView setImage:image];
                                        
                                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                        NSLog(@"Error -- fetching image");
                                        __strong ArtistCell *strongSelf = weakSelf;
                                        [strongSelf.progressView stopAnimating];
                                    }];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return NO; //todo!
}

#pragma mark - MGTableCell


@end
