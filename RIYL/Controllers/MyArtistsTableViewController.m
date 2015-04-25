#import <MGSwipeTableCell/MGSwipeButton.h>
#import "MyArtistsTableViewController.h"
#import "SimilarViewController.h"
#import "DetailViewController.h"
#import "Artist.h"
#import "ArtistCell.h"
#import "UIColor+HexColors.h"
#import "ArtistCell+Artist.h"
#import "UIViewController+Integrations.h"
#import <libextobjc/EXTScope.h>

@interface MyArtistsTableViewController () <MGSwipeTableCellDelegate>
@end

static NSString *CellIdentifier = @"ArtistCell";
static NSString *ViewSimilarIdentifier = @"viewSimilar";
static NSString *ViewDetailsIdentifier = @"viewDetails";
static NSString *AddArtistIdentifier = @"addArtist";

@implementation MyArtistsTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchAllNowListeningArtists];
    [self.tableView reloadData];
    [self animateNavigationBarTintColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"My Artists";
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor blackColor];
    [self.tableView registerClass:[ArtistCell class]
           forCellReuseIdentifier:CellIdentifier];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)animateNavigationBarTintColor
{
    @weakify(self)
    [self.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        @strongify(self)
        [self refreshNavigationBarColorScheme];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if (![context isCancelled]) {
            [self refreshNavigationBarTintColor];
            [self refreshStatusBarColorScheme];
        }
    }];
}

- (void)refreshNavigationBarColorScheme
{
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.barTintColor = [UIColor myDarkGrayColor];
}

- (void)refreshNavigationBarTintColor
{
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.tintColor = [UIColor whiteColor];
    navigationBar.titleTextAttributes = ({
        @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    });
}

- (void)refreshStatusBarColorScheme
{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

#pragma mark - UITableViewDatasource

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ArtistCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.delegate = self;
    
    Artist *artist = [self artistForIndexPath:indexPath];
    [cell updateWithArtist:artist];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.artists.count;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:ViewDetailsIdentifier
                              sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

#pragma mark - MGSwipeTableCellDelegate

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell
              canSwipe:(MGSwipeDirection)direction
{
    return YES;
}

- (NSArray *)swipeTableCell:(ArtistCell *)cell
   swipeButtonsForDirection:(MGSwipeDirection)direction
              swipeSettings:(MGSwipeSettings *)swipeSettings
          expansionSettings:(MGSwipeExpansionSettings *)expansionSettings
{
    swipeSettings.transition = MGSwipeTransitionBorder;
    expansionSettings.buttonIndex = 0;
    expansionSettings.fillOnTrigger = direction == MGSwipeDirectionRightToLeft;
    
    if (direction == MGSwipeDirectionRightToLeft) {
        return [self createRightButtons];
    } else {
        Artist *artist = [self artistForCell:cell];
        return [self createLeftButtons:artist];
    }
}

- (BOOL)swipeTableCell:(ArtistCell *)cell
   tappedButtonAtIndex:(NSInteger)index
             direction:(MGSwipeDirection)direction
         fromExpansion:(BOOL)fromExpansion
{
    BOOL swipeRight = direction == MGSwipeDirectionLeftToRight;
    BOOL isSpotify = swipeRight && index == 0;
    BOOL isYoutube = swipeRight && !isSpotify;
    BOOL isDelete = !swipeRight && index == 0;
    
    if (isDelete) {
        [self deleteArtistForCell:cell];
    } else if (isSpotify) {
        [self spotifyTapped:[self artistForCell:cell]];
    } else if (isYoutube) {
        [self youtubeTapped:[self artistForCell:cell]];
    }
    
    return YES;
}

- (NSArray *)createLeftButtons:(Artist*)artist
{
    if ([self userHasSpotifyInstalled]) {
        return @[[self createSpotifyButton]];
    } else if ([self userHasYoutubeInstalled]) {
        return @[[self createYoutubeButton]];
    } else {
         return nil;
    }
}

- (MGSwipeButton *)createSpotifyButton
{
    MGSwipeButton *spotifyButton = ({
        // Create properly sized icon
        UIImage *icon = [UIImage imageNamed:@"ListenSpotifyWide"];
        CGSize iconSize = CGSizeMake(136.f, 50.0f);
        UIGraphicsBeginImageContextWithOptions(iconSize, NO, 0.0);
        [icon drawInRect:CGRectMake(0, 0, iconSize.width, iconSize.height)];
        icon = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIColor *color = [UIColor mySpotifyGreenColor];
        UIEdgeInsets insets = UIEdgeInsetsMake(15, 0, 15, 0);
        [MGSwipeButton buttonWithTitle:nil icon:icon backgroundColor:color insets:insets];
    });
    [spotifyButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    spotifyButton.contentMode = UIViewContentModeScaleAspectFit;
    return spotifyButton;
}

- (MGSwipeButton *)createYoutubeButton
{
    MGSwipeButton *youtubeButton = ({
        // Create properly sized icon
        UIImage *icon = [UIImage imageNamed:@"ListenYoutube"];
        CGSize iconSize = CGSizeMake(71.f, 50.f);
        UIGraphicsBeginImageContextWithOptions(iconSize, NO, 0.0);
        [icon drawInRect:CGRectMake(0, 0, iconSize.width, iconSize.height)];
        icon = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIColor *color = [UIColor myYoutubeRedColor];
        UIEdgeInsets insets = UIEdgeInsetsMake(20, 20, 20, 20);
        [MGSwipeButton buttonWithTitle:nil icon:icon backgroundColor:color insets:insets];
    });
    [youtubeButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    youtubeButton.contentMode = UIViewContentModeScaleAspectFit;
    return youtubeButton;
}

- (NSArray *)createRightButtons
{
    MGSwipeButton *delete = ({
        NSString *title = @"Delete";
        UIColor *color = [UIColor redColor];
        NSInteger padding = 15;
        [MGSwipeButton buttonWithTitle:title backgroundColor:color padding:padding];
    });
    return @[delete];
    
}

#pragma mark - Navigation methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    NSIndexPath *selected = [self.tableView indexPathForSelectedRow];
    
    if ([segue.identifier isEqual:ViewSimilarIdentifier]) {
        SimilarViewController *upcoming = segue.destinationViewController;
        upcoming.artist = [self artistForIndexPath:selected];
        
    } else if ([segue.identifier isEqual:ViewDetailsIdentifier]) {
        DetailViewController *upcoming = segue.destinationViewController;
        upcoming.artist = [self artistForIndexPath:selected];
        
    } else if ([segue.identifier isEqual:AddArtistIdentifier]) {
        DetailViewController *upcoming = segue.destinationViewController;
        [upcoming prepareForAddArtist];
    }
}

#pragma mark - Private helper methods

- (Artist*)artistForIndexPath:(NSIndexPath *)indexPath
{
    return self.artists[indexPath.row];
}

- (Artist *)artistForCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    return [self artistForIndexPath:indexPath];
}

- (void)fetchAllNowListeningArtists
{
    NSPredicate *nowListening = [NSPredicate predicateWithFormat:@"nowListening == YES"];
    NSArray *artists = [Artist MR_findAllSortedBy:@"name"
                                        ascending:YES
                                    withPredicate:nowListening];
    
    // case-insensitive sorting
    self.artists = [[artists sortedArrayUsingComparator:[self artistComparator]] mutableCopy];
}

- (NSComparator)artistComparator
{
    return ^NSComparisonResult(id obj1, id obj2) {
        NSString *a1 = [obj1 name];
        NSString *a2 = [obj2 name];
        
        // Ignore "The"
        if ([a1 hasPrefix:@"The "] || [a1 hasPrefix:@"the "]) {
            a1 = [a1 substringFromIndex:4];
        }
        if ([a2 hasPrefix:@"The "] || [a2 hasPrefix:@"the "]) {
            a2 = [a2 substringFromIndex:4];
        }
        
        // Ignore "A "
        if ([a1 hasPrefix:@"A "] || [a1 hasPrefix:@"a "]) {
            a1 = [a1 substringFromIndex:4];
        }
        if ([a2 hasPrefix:@"A "] || [a2 hasPrefix:@"a "]) {
            a2 = [a2 substringFromIndex:4];
        }
        
        return [a1 caseInsensitiveCompare:a2];
    };
}

- (BOOL)deleteArtistForCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Artist *artist = [self artistForIndexPath:indexPath];
    
    // Archive artist by marking as not-listening
    artist.nowListening = @NO;
    
    [self.artists removeObject:artist];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
    [self saveContext];
    return YES;
}

- (BOOL)viewDetailsForArtistAtCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView selectRowAtIndexPath:indexPath
                                animated:NO
                          scrollPosition:UITableViewScrollPositionNone];
    [self performSegueWithIdentifier:ViewDetailsIdentifier sender:self];
    return YES;
}

- (void)saveContext
{
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

@end
