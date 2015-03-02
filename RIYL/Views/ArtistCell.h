@import UIKit;
@class Artist;
#import <SpinKit/RTSpinKitView.h>
#import <MGSwipeTableCell/MGSwipeTableCell.h>

@interface ArtistCell : MGSwipeTableCell

@property (nonatomic) RTSpinKitView *progressView;
@property (nonatomic) UIImageView *backgroundImageView;
@property (nonatomic) UILabel *label;

@end
