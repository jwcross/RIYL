#import "ArtistCell+Artist.h"
#import "Artist.h"
#import "UIColor+HexColors.h"
#import <libextobjc/EXTScope.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation ArtistCell (Artist)

- (void)updateWithArtist:(Artist *)artist
{
    self.label.text = artist.name;
    self.label.backgroundColor = [UIColor myTransparentDarkGrayColor];
    
    [self fetchBackgroundImageForArtist:artist];
}

typedef void (^ImageSuccess)(NSURLRequest*, NSHTTPURLResponse*, UIImage*);
typedef void (^ImageError)(NSURLRequest*, NSHTTPURLResponse*, NSError*);

- (void)fetchBackgroundImageForArtist:(Artist*)artist
{
    // Clear background image
    self.backgroundImageView.image = nil;
    
    // Return early if artist has no images
    if (artist.images.count == 0) {
        return;
    }
    
    // Start loading animation
    [self.progressView startAnimating];
    
    // Define callbacks
    @weakify(self)
    ImageSuccess success = ^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        @strongify(self)
        [self.progressView stopAnimating];
        self.backgroundImageView.image = image;
    };
    ImageError failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        @strongify(self)
        [self.progressView stopAnimating];
    };
    
    // Fetch artist image and clear spinner on success
    NSURL *imageUrl = [NSURL URLWithString:[artist.images.firstObject text]];
    [self.backgroundImageView setImageWithURLRequest:[NSURLRequest requestWithURL:imageUrl]
                                    placeholderImage:nil
                                             success:success
                                             failure:failure];
}

@end
