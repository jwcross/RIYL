//
//  ArtistCell.m
//  SimilarArtists
//
//  Created by Jonathan Crossley on 9/2/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MGSwipeTableCell/MGSwipeButton.h>
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
        [self.contentView addSubview:_label];
        
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
      
        // MGSwipeTableCell settings
        self.leftExpansion.buttonIndex = 0;
        self.leftExpansion.fillOnTrigger = NO;
        self.rightExpansion.buttonIndex = 0;
        self.rightExpansion.fillOnTrigger = YES;
        self.leftSwipeSettings.transition = MGSwipeTransitionBorder;
        self.rightSwipeSettings.transition = MGSwipeTransitionBorder;
      
        // swipe buttons
        self.leftButtons = [self createLeftButtons];
        self.rightButtons = [self createRightButtons];
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

#pragma mark - MGTableCell

-(NSArray *)createLeftButtons {
  NSMutableArray *result = [NSMutableArray array];
  UIColor *colors[2] = {
    [UIColor greenColor],
    [UIColor colorWithRed:0 green:0x99/255.0 blue:0xcc/255.0 alpha:1.0],
  };
  
  NSString *titles[2] = {@"Like", @"Unlike"};
  
  for (int i = 0; i < 2; ++i) {
    MGSwipeButton *button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] padding:15
        callback:^BOOL(MGSwipeTableCell *sender) {
          NSLog(@"Convenience callback received (left).");
          return YES;
    }];
    [result addObject:button];
  }
  return result;
}

-(NSArray *)createRightButtons {
  NSMutableArray *result = [NSMutableArray array];
  NSString *titles[2] = {@"Delete", @"More"};
  UIColor *colors[2] = {[UIColor redColor], [UIColor lightGrayColor]};
  
  for (int i = 0; i < 2; ++i) {
    MGSwipeButton *button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] padding:15
        callback:^BOOL(MGSwipeTableCell *sender) {
          NSLog(@"Convenience callback received (right).");
          return YES;
    }];
    [result addObject:button];
  }
  return result;
}


@end
