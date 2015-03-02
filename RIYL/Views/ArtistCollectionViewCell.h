#import <UIKit/UIKit.h>
#import "Artist.h"

// A custom collection view cell that renders Artist items.
@interface ArtistCollectionViewCell : UICollectionViewCell

// the item that this cell renders.
@property (nonatomic) Artist *artist;

// the label used to render the artist name.
@property (nonatomic, strong) IBOutlet UILabel *label;

@end
