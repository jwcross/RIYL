#import <UIKit/UIKit.h>
#import "Artist.h"

@interface DetailViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) Artist *artist;

@property (weak, nonatomic) IBOutlet UITextView *artistDetailsView;
@property (weak, nonatomic) IBOutlet UIImageView *artistImage;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *readMoreButton;
@property (weak, nonatomic) IBOutlet UIButton *openInButton;
@property (weak, nonatomic) IBOutlet UIView *divider1;
@property (weak, nonatomic) IBOutlet UIView *divider2;

- (IBAction)readMoreAction:(id)sender;
- (IBAction)openArtistAction:(id)sender;

- (void)prepareForAddArtist;
- (void)prepareForSimilarArtist;
- (void)cancelAdd;
- (void)addNewArtist;

@end

