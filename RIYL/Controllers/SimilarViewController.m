#import "SimilarViewController.h"
#import "ArtistCollectionViewCell.h"
#import "LastfmAPIClient.h"
#import "SpotifyAPIClient.h"
#import "Artist.h"
#import "Image.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <SpinKit/RTSpinKitView.h>
#import <libextobjc/EXTScope.h>

@interface SimilarViewController ()
@property NSMutableArray *similarArtists;
@end

@implementation SimilarViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // if we don't yet have associated similarArtists, fetch from API
    if (self.artist.similarArtists.count == 0) {
        [self getSimilarArtists];
        [self.collectionView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Similar Artists";
    // Register cell class
    UINib *cellNib = [UINib nibWithNibName:@"ArtistCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // Save context as view disappears.
    [self saveContext];
}


#pragma mark - UICollectionViewDataSource


- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return [self.artist.similarArtists count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ArtistCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                               forIndexPath:indexPath];
    cell.artist = self.artist.similarArtists[indexPath.row];
    return cell;
}

#pragma mark -
#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Artist *selectedArtist = self.artist.similarArtists[indexPath.row];
    UIAlertController *actionSheet = [self alertControllerForArtist:selectedArtist];
    if (actionSheet) {
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}

- (UIAlertController*)alertControllerForArtist:(Artist*)artist {
    if (![self userHasSpotifyInstalled]) {
        return nil;
    }

    // Create the action sheet
    UIAlertController *actionSheet = ({
        UIAlertControllerStyle style = UIAlertControllerStyleActionSheet;
        [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:style];
    });
    
    // Define the spotify and cancel actions
    UIAlertAction *spotifyAction = ({
        NSString *title = @"Spotify";
        UIAlertActionStyle style = UIAlertActionStyleDefault;
        @weakify(self)
        [UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction *action) {
            @strongify(self)
            [self spotifyTapped:artist];
        }];
    });
    UIAlertAction *cancelAction = ({
        NSString *title = @"Cancel";
        UIAlertActionStyle style = UIAlertActionStyleCancel;
        [UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction *action) {
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
        }];
    });
    
    // Add the actions
    [actionSheet addAction:spotifyAction];
    [actionSheet addAction:cancelAction];
    
    return actionSheet;
}

- (BOOL)userHasSpotifyInstalled {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"spotify:"]];
}

- (void)spotifyTapped:(Artist*)artist {
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

#pragma mark -
#pragma mark UICollectionViewFlowLayoutDelegate

CGFloat CELL_MARGIN = 20.0f;

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // square size for equally-spaced two-column layout
    CGFloat cellWidth = (self.view.bounds.size.width - 3 * CELL_MARGIN) / 2;
    return CGSizeMake(cellWidth, cellWidth);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return CELL_MARGIN;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                       layout:(UICollectionViewLayout *)collectionViewLayout
       insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(CELL_MARGIN, CELL_MARGIN, CELL_MARGIN, CELL_MARGIN);
}

#pragma mark -
#pragma mark Private helpers

-(void)saveContext
{
    @weakify(self)
    [[NSManagedObjectContext MR_defaultContext]
     MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
         @strongify(self)
         if (success) {
             NSLog(@"%tu similar artists successfully saved.", self.similarArtists.count);
         } else if (error) {
             NSLog(@"Error saving %tu similar artists: %@", self.similarArtists.count, error.description);
         }
     }];
}

-(void)getSimilarArtists
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = NSLocalizedString(@"Loading similar artists", @"Loading similar artists");
    hud.customView = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWave
                                                    color:[UIColor whiteColor]];
    [(RTSpinKitView*)hud.customView startAnimating];
    
    // get artist details
    LastfmAPIClient *api = [LastfmAPIClient sharedClient];
    [api getSimilarArtistsForArtist:self.artist.name limit:20 autocorrect:YES
         success:^(NSURLSessionDataTask *task, id responseObject) {
             NSArray *similar = responseObject[@"similarartists"][@"artist"];
             NSLog(@"Success -- %tu artists", similar.count);
             [self saveSimilarArtistsForResponse:similar];
             [self.collectionView reloadData];
             [hud hide:YES];
             
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             NSLog(@"Failure -- %@", error.description);
             [hud hide:YES];
         }];
}

-(void)saveSimilarArtistsForResponse:(NSArray*)similarArtists
{
    NSMutableArray *newSimilar = [NSMutableArray array];
    for (NSDictionary *artistDict in similarArtists) {
        // 1. Check if artist already exists in table
        Artist *similar;
        if ([artistDict[@"mbid"] length] > 0) {
            similar = [Artist MR_findFirstByAttribute:@"mbid"
                                            withValue:artistDict[@"mbid"]];
        } else {
            NSLog(@"ERROR: Artist has empty mbid.\nname = %@\nid = %@",
                   artistDict[@"name"], artistDict[@"id"]);
        }
        
        if (similar) {
            NSLog(@"Found similar artist in table");
            
        } else {
            similar = [Artist MR_createEntity]; //todo! save, add relationship to seed
            similar.name = artistDict[@"name"];
            similar.mbid = artistDict[@"mbid"];

            if ([artistDict[@"image"] count] > 0) {
                Image *image = [Image MR_createEntity];
                image.text = [artistDict[@"image"] lastObject][@"#text"];
                image.size = [artistDict[@"image"] lastObject][@"size"];
                image.artist = self.artist;
                
                [similar addImagesObject:image];
            }
        }
        [newSimilar addObject:similar];
    }
    self.artist.similarArtists = [[NSOrderedSet alloc] initWithArray:newSimilar];
    self.similarArtists = newSimilar;
    [self.collectionView reloadData];
}

@end
