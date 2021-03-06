#import <UIKit/UIKit.h>
#import "Artist.h"
#import "HighlightButton.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) Artist *artist;

@property (weak, nonatomic) IBOutlet UITextView *artistDetailsView;
@property (weak, nonatomic) IBOutlet UIImageView *artistImage;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

// TODO: Replace with UITableView
@property (weak, nonatomic) IBOutlet UIView *divider1;
@property (weak, nonatomic) IBOutlet UIView *divider2;
@property (weak, nonatomic) IBOutlet UIView *divider3;
@property (weak, nonatomic) IBOutlet HighlightButton *addToMyArtistsButton;
@property (weak, nonatomic) IBOutlet HighlightButton *readMoreButton;
@property (weak, nonatomic) IBOutlet HighlightButton *openInButton;

- (IBAction)readMoreAction:(id)sender;
- (IBAction)openArtistAction:(id)sender;

- (void)prepareForAddArtist;
- (void)prepareForSimilarArtist;
- (void)cancelAdd;
- (void)addNewArtist;

@end

