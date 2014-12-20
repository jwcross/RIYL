//
//  ArtistCell.h
//  SimilarArtists
//
//  Created by Jonathan Crossley on 9/2/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MGSwipeTableCell/MGSwipeTableCell.h>
#import "Artist.h"

// A custom table view cell that renders Artist items.
@interface ArtistCell : MGSwipeTableCell <UITextFieldDelegate>

// the item that this cell renders.
@property (nonatomic) Artist *artist;

// the label used to render the artist name.
@property (nonatomic, strong, readonly) UITextField *label;

@end
