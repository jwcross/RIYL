#import "SimilarViewController.h"
#import "DetailViewController.h"
#import "ArtistCollectionViewCell.h"
#import "LastfmAPIClient.h"
#import "Artist.h"
#import "Image.h"
#import "UIViewController+Integrations.h"
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

#pragma mark - 
#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"viewDetail"]) {
        DetailViewController *detailViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
        detailViewController.artist = self.artist.similarArtists[indexPath.row];
        [detailViewController prepareForSimilarArtist];
    }
}

#pragma mark -
#pragma mark UICollectionViewDataSource

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
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // select cell (in order to find in prepareForSegue)
    [self.collectionView selectItemAtIndexPath:indexPath
                                      animated:NO
                                scrollPosition:UICollectionViewScrollPositionNone];
    // launch detail view
    [self performSegueWithIdentifier:@"viewDetail" sender:self];
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
    
    // get similar artists
    @weakify(self)
    LastfmAPIClient *api = [LastfmAPIClient sharedClient];
    [api getSimilarArtistsForArtist:self.artist.name limit:20 autocorrect:NO
         success:^(NSURLSessionDataTask *task, id responseObject) {
             @strongify(self)
             NSArray *similar = responseObject[@"similarartists"][@"artist"];
             
             if (![similar isKindOfClass:[NSArray class]]) {
                 NSLog(@"Failure -- API returned a string instead of an array of artists");
                 NSLog(@"Failure -- %@", responseObject);
                 
                 // Show error dialog
                 [(RTSpinKitView*)hud.customView stopAnimating];
                 hud.mode = MBProgressHUDModeText;
                 hud.labelText = @"Error loading artists";
                 
                 return;
             }
             NSLog(@"Success -- %tu artists", similar.count);
             [self saveSimilarArtistsForResponse:similar];
             [self.collectionView reloadData];
             [hud hide:YES];
             
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             NSLog(@"Failure -- %@", error.description);
             [hud hide:YES];
         }];
}

- (void)saveSimilarArtistsForResponse:(NSArray*)similarDicts
{
    NSMutableArray *newSimilar = [NSMutableArray array];
    for (NSDictionary *artistDict in similarDicts) {
        NSLog(@"Processing artist: %@", artistDict[@"name"]);
        
        // 1. Check if artist already exists in table
        Artist *similar;
        if ([artistDict[@"mbid"] length] == 0) {
            NSLog(@"ERROR: Artist has empty mbid.");
        } else {
            similar = [Artist MR_findFirstByAttribute:@"mbid" withValue:artistDict[@"mbid"]];
        }
        
        // 2. If no matching artist found, create a new one
        if (!similar) {
            NSLog(@"Artist not found, creating new entity");
            similar = [self createSimilarArtistForDictionary:artistDict];
        }
        
        // 3. Add to results
        [newSimilar addObject:similar];
    }
    self.artist.similarArtists = [[NSOrderedSet alloc] initWithArray:newSimilar];
    self.similarArtists = newSimilar;
    [self.collectionView reloadData];
}

- (Artist *)createSimilarArtistForDictionary:(NSDictionary *)artistDict
{
    Artist *similar = [Artist MR_createEntity]; //todo! save, add relationship to seed
    similar.name = artistDict[@"name"];
    similar.mbid = artistDict[@"mbid"];
    
    NSDictionary *bestImage = [artistDict[@"image"] lastObject];
    if (bestImage) {
        Image *image = [Image MR_createEntity];
        image.text = bestImage[@"#text"];
        image.size = bestImage[@"size"];
        image.artist = self.artist;
        [similar addImagesObject:image];
    }
    return similar;
}

@end
