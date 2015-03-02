@import UIKit;
@class Artist;
#import <MGSwipeTableCell/MGSwipeTableCell.h>

@interface ArtistCell : MGSwipeTableCell

// The Artist that this cell renders.
@property (nonatomic) Artist *artist;

@end
