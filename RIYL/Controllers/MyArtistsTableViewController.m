#import <MGSwipeTableCell/MGSwipeButton.h>
#import "MyArtistsTableViewController.h"
#import "SimilarViewController.h"
#import "DetailViewController.h"
#import "Artist.h"
#import "ArtistCell.h"
#import "UIColor+HexColors.h"
#import "ArtistCell+Artist.h"
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    [self performSegueWithIdentifier:ViewSimilarIdentifier sender:self];
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
    BOOL isLike = direction == MGSwipeDirectionLeftToRight;
    BOOL isDelete = !isLike && index == 0;
    BOOL isDetails = !isLike && index == 1;
    
    if (isDelete) {
        [self deleteArtistForCell:cell];
    } else if (isLike) {
        [self updateLikedForArtistAtCell:cell];
    } else if (isDetails) {
        [self viewDetailsForArtistAtCell:cell];
    }
    
    return YES;
}

- (NSArray *)createLeftButtons:(Artist*)artist
{
    UIColor *colors[] = {
        [UIColor myGreenColor],
        [UIColor myBlueColor],
        [UIColor myRedColor],
        [UIColor myBlueColor]
    };
    NSString *titles[] = { @"Like", @"Unlike", @"Dislike", @"Undislike" };
    long position = artist.liked.integerValue % 4;
    
    MGSwipeButton *likeUnlikeButton = ({
        UIColor *color = colors[position];
        NSString *title = titles[position];
        NSInteger padding = 15;
        [MGSwipeButton buttonWithTitle:title backgroundColor:color padding:padding];
    });
    
    return @[likeUnlikeButton];
}

- (NSArray *)createRightButtons
{
    NSInteger padding = 15;
    
    MGSwipeButton *delete = ({
        NSString *title = @"Delete";
        UIColor *color = [UIColor myRedColor];
        [MGSwipeButton buttonWithTitle:title backgroundColor:color padding:padding];
    });
    MGSwipeButton *more = ({
        NSString *title = @"Details";
        UIColor *color = [UIColor lightGrayColor];
        [MGSwipeButton buttonWithTitle:title backgroundColor:color padding:padding];
    });
    
    return @[delete, more];
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
    self.artists = [[Artist MR_findAllSortedBy:@"name"
                                     ascending:YES
                                 withPredicate:nowListening] mutableCopy];
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

- (BOOL)updateLikedForArtistAtCell:(UITableViewCell *)cell
{
    Artist *artist = [self artistForCell:cell];
    artist.liked = @((artist.liked.integerValue + 1) % 4); // meh, liked, meh, disliked
    [self saveContext];
    [self.tableView reloadData];
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
