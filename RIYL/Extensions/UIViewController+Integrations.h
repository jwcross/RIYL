#import <UIKit/UIKit.h>
#import "Artist.h"
#import "SpotifyAPIClient.h"

@interface UIViewController (Integrations)

- (UIAlertController *)readIntegrationsSheetForArtist:(Artist *)artist;
- (UIAlertController *)integrationsSheetForArtist:(Artist *)artist;
- (BOOL)userHasSpotifyInstalled;
- (BOOL)userHasYoutubeInstalled;

- (void)spotifyTapped:(Artist*)artist;
- (void)youtubeTapped:(Artist*)artist;

@end
