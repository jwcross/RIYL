//
//  SimilarViewController.m
//  SimilarArtists
//
//  Created by Jonathan Crossley on 9/3/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import "SimilarViewController.h"
#import "ArtistCollectionViewCell.h"
#import "LastfmAPIClient.h"
#import "Image.h"

@interface SimilarViewController ()
@property NSMutableArray *similarArtists;
@end

@implementation SimilarViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // if we don't yet have associated similarArtists, fetch from API
    NSLog(@"similarArtists.count = %d", self.artist.similarArtists.count);
    if (self.artist.similarArtists.count == 0) {
        [self getSimilarArtists];
        [self.collectionView reloadData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Similar Artists";
    // Register cell class
    UINib *cellNib = [UINib nibWithNibName:@"ArtistCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:reuseIdentifier];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // Save context as view disappears.
    [self saveContext];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


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

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // todo!
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // todo!
}

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

#pragma mark - UICollectionViewFlowLayoutDelegate

CGFloat CELL_MARGIN = 20.0f;

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
 sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // square size for equally-spaced two-column layout
    CGFloat cellWidth = (self.view.bounds.size.width - 3 * CELL_MARGIN) / 2;
    return CGSizeMake(cellWidth, cellWidth);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return CELL_MARGIN;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(CELL_MARGIN, CELL_MARGIN, CELL_MARGIN, CELL_MARGIN);
}

#pragma mark - Private helpers
-(void)saveContext {
    [[NSManagedObjectContext defaultContext]
     saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
         if (success) {
             NSLog(@"%d similar artists successfully saved.", _similarArtists.count);
         } else if (error) {
             NSLog(@"Error saving %d similar artists: %@", _similarArtists.count, error.description);
         }
    }];
}

-(void)getSimilarArtists {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading similar artists";
    
    // get artist details
    LastfmAPIClient *api = [LastfmAPIClient sharedClient];
    [api getSimilarArtistsForArtist:self.artist.name limit:20 autocorrect:YES
         success:^(NSURLSessionDataTask *task, id responseObject) {
             NSArray *similar = responseObject[@"similarartists"][@"artist"];
             NSLog(@"Success -- %d artists", similar.count);
             [hud hide:YES];
             [self saveSimilarArtistsForResponse:similar];
             [self.collectionView reloadData];
             
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             NSLog(@"Failure -- %@", error.description);
             [hud hide:YES];
         }];
}

-(void)saveSimilarArtistsForResponse:(NSArray*)similarArtists {
    NSMutableArray *newSimilar = [NSMutableArray array];
    
    for (NSDictionary *artistDict in similarArtists) {
        Artist *similar = [Artist createEntity]; //todo! save, add relationship to seed
        similar.name = artistDict[@"name"];
        similar.mbid = artistDict[@"mbid"];

        if ([artistDict[@"image"] count] > 0) {
            Image *image = [Image createEntity];
            image.text = [artistDict[@"image"] lastObject][@"#text"];
            image.size = [artistDict[@"image"] lastObject][@"size"];
            image.artist = self.artist;
            
            [similar addImagesObject:image];
        }
        
        [newSimilar addObject:similar];
    }
    
    self.artist.similarArtists = [[NSOrderedSet alloc] initWithArray:newSimilar];
    self.similarArtists = newSimilar;
    [self.collectionView reloadData];
}

@end
