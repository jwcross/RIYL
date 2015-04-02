#import <UIKit/UIKit.h>
#import "Artist.h"
#import "SpotifyAPIClient.h"

@interface UIViewController (Integrations)

- (BOOL)userHasSpotifyInstalled;
- (BOOL)userHasPandoraInstalled;

- (UIAlertAction *)spotifyActionForArtist:(Artist *)artist;
- (UIAlertAction *)pandoraActionForArtist:(Artist *)artist;

@end

@implementation UIViewController (Integrations)

#pragma mark - Spotify

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

#pragma mark - Pandora

- (BOOL)userHasPandoraInstalled
{
    NSURL *pandoraURL = [NSURL URLWithString:@"pandorav2:"];
    return [[UIApplication sharedApplication] canOpenURL:pandoraURL];
}


- (UIAlertAction *)pandoraActionForArtist:(Artist *)artist
{
    return ({
        NSString *title = @"Pandora";
        UIAlertActionStyle style = UIAlertActionStyleDefault;
        [UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction *action) {
            [self pandoraTapped:artist];
        }];
    });
}

- (void)pandoraTapped:(Artist *)artist
{
    NSString *pandoraURI = ({
        NSString *name = [artist.name stringByReplacingOccurrencesOfString:@" "
                                                                withString:@"+"];
        [NSString stringWithFormat:@"pandorav2:/createStation?artist=%@", name];
    });
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:pandoraURI]];
}

@end
