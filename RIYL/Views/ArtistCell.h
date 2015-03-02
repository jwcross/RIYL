#import <UIKit/UIKit.h>
#import <MGSwipeTableCell/MGSwipeTableCell.h>
#import "Artist.h"

// A custom table view cell that renders Artist items.
@interface ArtistCell : MGSwipeTableCell

// the item that this cell renders.
@property (nonatomic) Artist *artist;

// the label used to render the artist name.
@property (nonatomic, strong, readonly) UILabel *label;

@end
