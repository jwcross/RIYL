#import <UIKit/UIKit.h>
#import "Artist.h"

@interface SimilarViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) Artist *artist;

@end
