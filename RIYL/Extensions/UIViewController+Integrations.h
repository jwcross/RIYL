#import <UIKit/UIKit.h>
#import "Artist.h"
#import "SpotifyAPIClient.h"

@interface UIViewController (Integrations)

- (UIAlertController *)readIntegrationsSheetForArtist:(Artist *)artist;
- (UIAlertController *)integrationsSheetForArtist:(Artist *)artist;
- (void)spotifyTapped:(Artist*)artist;
- (BOOL)userHasSpotifyInstalled;

@end
