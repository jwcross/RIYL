#import <UIKit/UIKit.h>
#import "Artist.h"

@interface DetailViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) Artist *artist;
@property (weak, nonatomic) IBOutlet UIImageView *artistImage;
@property (weak, nonatomic) IBOutlet UITextView *artistDetailsView;

-(void)cancelAdd;
-(void)addNewArtist;

@end

