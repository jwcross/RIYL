#import <UIKit/UIKit.h>
#import "Artist.h"
#import "SpotifyAPIClient.h"

@interface UIViewController (Integrations)

- (BOOL)userHasSpotifyInstalled;

- (UIAlertAction *)spotifyActionForArtist:(Artist *)artist;

@end

@implementation UIViewController (Integrations)


- (BOOL)userHasSpotifyInstalled
{
    NSURL *spotifyURL = [NSURL URLWithString:@"spotify:"];
    return [[UIApplication sharedApplication] canOpenURL:spotifyURL];
}

- (UIAlertAction *)spotifyActionForArtist:(Artist *)artist
{
    return ({
        NSString *title = @"Spotify";
        UIAlertActionStyle style = UIAlertActionStyleDefault;
        [UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction *action) {
            [self spotifyTapped:artist];
        }];
    });
}

- (void)spotifyTapped:(Artist*)artist
{
    SuccessCallback success = ^(NSURLSessionDataTask *task, id response) {
        BOOL didReturnArtist = [response[@"artists"][@"items"] count] > 0;
        if (didReturnArtist) {
            NSString *spotifyID = response[@"artists"][@"items"][0][@"id"];
            NSString *spotifyURI = [NSString stringWithFormat:@"spotify:artist:%@", spotifyID];
            NSURL *url = [NSURL URLWithString:spotifyURI];
            [[UIApplication sharedApplication] openURL:url];
        }
    };
    [[SpotifyAPIClient sharedClient] getArtistByName:artist.name success:success failure:nil];
}

@end
