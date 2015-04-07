#import <UIKit/UIKit.h>
#import "Artist.h"
#import "SpotifyAPIClient.h"

@interface UIViewController (Integrations)

- (UIAlertController *)integrationsSheetForArtist:(Artist *)artist;
- (void)spotifyTapped:(Artist*)artist;
- (BOOL)userHasSpotifyInstalled;

@end

@implementation UIViewController (Integrations)

#pragma mark - Generic

- (UIAlertController *)integrationsSheetForArtist:(Artist *)artist
{
    UIAlertController *actionSheet = ({
        UIAlertControllerStyle style = UIAlertControllerStyleActionSheet;
        [UIAlertController alertControllerWithTitle:nil
                                            message:nil
                                     preferredStyle:style];
    });
    
    // iTunes action
    [actionSheet addAction:[self itunesActionForArtist:artist]];
    
    // Spotify action
    if ([self userHasSpotifyInstalled]) {
        [actionSheet addAction:[self spotifyActionForArtist:artist]];
    }
    
    // Pandora action
    if ([self userHasPandoraInstalled]) {
        [actionSheet addAction:[self pandoraActionForArtist:artist]];
    }
    
    // YouTube action
    if ([self userHasYoutubeInstalled]) {
        [actionSheet addAction:[self youtubeActionForArtist:artist]];
    }
    
    // Cancel action
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                    style:UIAlertActionStyleCancel
                                                  handler:nil]];
    
    return actionSheet;
}

- (UIAlertAction *)actionWithTitle:(NSString *)title
                           handler:(void(^)(UIAlertAction *action))handler
{
    return [UIAlertAction actionWithTitle:title
                                    style:UIAlertActionStyleDefault
                                  handler:handler];
}

#pragma mark - iTunes

- (UIAlertAction *)itunesActionForArtist:(Artist *)artist
{
    return [self actionWithTitle:@"iTunes" handler:^(UIAlertAction *action) {
        [self itunesTapped:artist];
    }];
}

- (void)itunesTapped:(Artist*)artist
{
    NSString *base = @"itms://itunes.apple.com/WebObjects/MZStore.woa/wa/";
    NSString *args = ({
        NSString *format = @"media=music&entity=musicArtist&term=%@";
        NSString *name = [artist.name stringByReplacingOccurrencesOfString:@" "
                                                                withString:@"+"];
        [NSString stringWithFormat:format, name];
    });
    NSString *url = [NSString stringWithFormat:@"%@/search?%@", base, args];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

#pragma mark - YouTube

- (BOOL)userHasYoutubeInstalled
{
    NSURL *youtubeURL = [NSURL URLWithString:@"youtube:///"];
    return [[UIApplication sharedApplication] canOpenURL:youtubeURL];
}

- (UIAlertAction *)youtubeActionForArtist:(Artist *)artist
{
    return [self actionWithTitle:@"YouTube" handler:^(UIAlertAction *action) {
        [self youtubeTapped:artist];
    }];
}

- (void)youtubeTapped:(Artist*)artist
{
    NSString *base = @"youtube:///results";
    
    NSString *args = ({
        NSString *format = @"search_query=%@";
        NSString *name = [artist.name stringByReplacingOccurrencesOfString:@" "
                                                                withString:@"+"];
        [NSString stringWithFormat:format, name];
    });
    NSString *url = [NSString stringWithFormat:@"%@?%@", base, args];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

#pragma mark - Spotify

- (BOOL)userHasSpotifyInstalled
{
    NSURL *spotifyURL = [NSURL URLWithString:@"spotify:"];
    return [[UIApplication sharedApplication] canOpenURL:spotifyURL];
}

- (UIAlertAction *)spotifyActionForArtist:(Artist *)artist
{
    return [self actionWithTitle:@"Spotify" handler:^(UIAlertAction *action) {
        [self spotifyTapped:artist];
    }];
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
    return [self actionWithTitle:@"Pandora" handler:^(UIAlertAction *action) {
        [self pandoraTapped:artist];
    }];
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
