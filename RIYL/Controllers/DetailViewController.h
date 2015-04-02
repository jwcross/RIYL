#import <UIKit/UIKit.h>
#import "Artist.h"

@interface DetailViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) Artist *artist;

@property (weak, nonatomic) IBOutlet UITextView *artistDetailsView;
@property (weak, nonatomic) IBOutlet UIImageView *artistImage;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *readMoreLabel;

- (void)prepareForAddArtist;
- (void)prepareForSimilarArtist;
- (void)cancelAdd;
- (void)addNewArtist;
- (IBAction)readMoreAction:(id)sender;

@end

