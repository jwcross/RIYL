#import <MBProgressHUD/MBProgressHUD.h>
#import <SpinKit/RTSpinKitView.h>
#import "SimilarViewController.h"
#import "ArtistCollectionViewCell.h"
#import "LastfmAPIClient.h"
#import "SpotifyAPIClient.h"
#import <libextobjc/EXTScope.h>
#import "Image.h"

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

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // Save context as view disappears.
    [self saveContext];
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return [self.artist.similarArtists count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ArtistCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                               forIndexPath:indexPath];
    cell.artist = self.artist.similarArtists[indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Artist *selectedArtist = self.artist.similarArtists[indexPath.row];
    UIAlertController *actionSheet = [self alertControllerForArtist:selectedArtist];
    if (actionSheet) {
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // todo!
}

-(UIAlertController*)alertControllerForArtist:(Artist*)artist {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil
                                                                         message:nil
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
    typedef void (^AlertHandler)(UIAlertAction*);
    AlertHandler spotify = ^(UIAlertAction *action) {
        [self spotifyTapped:artist];
    };
    AlertHandler cancel = ^(UIAlertAction *action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    };
    
    if ([self userHasSpotifyInstalled]) {
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Spotify" style:UIAlertActionStyleDefault handler:spotify]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:cancel]];
        return actionSheet;
    }
    
    return nil;
}

-(BOOL)userHasSpotifyInstalled {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"spotify:"]];
}

-(void)spotifyTapped:(Artist*)artist {
    SuccessCallback success = ^(NSURLSessionDataTask *task, id response) {
        BOOL didReturnArtist = [response[@"artists"][@"items"] count] > 0;
        if (didReturnArtist) {
            NSString *spotifyID = response[@"artists"][@"items"][0][@"id"];
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"spotify:artist:%@", spotifyID]];
            [[UIApplication sharedApplication] openURL:url];
        }
    };
    [[SpotifyAPIClient sharedClient] getArtistByName:artist.name success:success failure:nil];
}

#pragma mark - UICollectionViewFlowLayoutDelegate

CGFloat CELL_MARGIN = 20.0f;

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // square size for equally-spaced two-column layout
    CGFloat cellWidth = (self.view.bounds.size.width - 3 * CELL_MARGIN) / 2;
    return CGSizeMake(cellWidth, cellWidth);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return CELL_MARGIN;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                       layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(CELL_MARGIN, CELL_MARGIN, CELL_MARGIN, CELL_MARGIN);
}

#pragma mark - UIAlertController



#pragma mark - Private helpers
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
    RTSpinKitView *spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWave color:[UIColor whiteColor]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = spinner;
    hud.labelText = NSLocalizedString(@"Loading similar artists", @"Loading similar artists");
    [spinner startAnimating];
    
    // get artist details
    LastfmAPIClient *api = [LastfmAPIClient sharedClient];
    [api getSimilarArtistsForArtist:self.artist.name limit:20 autocorrect:YES
         success:^(NSURLSessionDataTask *task, id responseObject) {
             NSArray *similar = responseObject[@"similarartists"][@"artist"];
             NSLog(@"Success -- %tu artists", similar.count);
             [hud hide:YES];
             [self saveSimilarArtistsForResponse:similar];
             [self.collectionView reloadData];
             
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
        
        if (similar != nil) {
            NSLog(@"Found similar artist in table");
            NSLog(@"debug: artistDict[@\"mbid\"] = %@", artistDict[@"mbid"]);
            NSLog(@"debug: similar.mbid = %@", similar.mbid);
            NSLog(@"debug: artistDict[@\"name\"] = %@", artistDict[@"name"]);
            NSLog(@"debug: similar.name = %@", similar.name);
            
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
