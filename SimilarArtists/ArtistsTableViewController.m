//
//  ArtistsTableViewController.m
//  SimilarArtists
//
//  Created by Jonathan Crossley on 8/29/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MGSwipeTableCell/MGSwipeButton.h>
#import "ArtistsTableViewController.h"
#import "DetailViewController.h"
#import "LastfmAPIClient.h"
#import "Artist.h"
#import "Image.h"
#import "ArtistCell.h"

@interface ArtistsTableViewController ()
@property NSMutableArray *artists;
@end

@implementation ArtistsTableViewController

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self fetchAllArtists];
  [self.tableView reloadData];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.title = @"My Artists";
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  self.tableView.backgroundColor = [UIColor blackColor];
}

#pragma mark - UITableViewDatasource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *identifier = @"ArtistCell";
  ArtistCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (!cell) {
    cell = [[ArtistCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
  }
  cell.delegate = self;
  
  cell.artist = self.artists[indexPath.row];
  [cell.label setUserInteractionEnabled:NO];
  return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.artists.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 80.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self performSegueWithIdentifier:@"viewArtist" sender:nil];
}

#pragma mark - MGSwipeTableCellDelegate

-(BOOL)swipeTableCell:(MGSwipeTableCell *)cell canSwipe:(MGSwipeDirection)direction
{
  return YES;
}

-(NSArray *)swipeTableCell:(MGSwipeTableCell *)cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings *)swipeSettings expansionSettings:(MGSwipeExpansionSettings *)expansionSettings
{
  swipeSettings.transition = MGSwipeTransitionBorder;
  expansionSettings.buttonIndex = 0;
  expansionSettings.fillOnTrigger = direction == MGSwipeDirectionRightToLeft;
  
  return direction == MGSwipeDirectionLeftToRight ? [self createLeftButtons]
       : direction == MGSwipeDirectionRightToLeft ? [self createRightButtons]
       : nil;
}

-(BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index
            direction:(MGSwipeDirection)direction    fromExpansion:(BOOL)fromExpansion {
  
  BOOL isDelete = index == 0 && direction == MGSwipeDirectionRightToLeft;
  if (isDelete) {
    // Deleting an Entity with MagicalRecord
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.artists[indexPath.row] deleteEntity];
    [self saveContext];
    [self.artists removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
  }
  
  NSLog(@"Callback received%@ (%@)",
    (fromExpansion ? @" from expansion" : @""),
    (direction == MGSwipeDirectionLeftToRight ? @"left" : @"right"));
  
  return YES;
}

-(NSArray *)createLeftButtons {
  UIColor *colors[2] = { [UIColor greenColor], [UIColor colorWithRed:0 green:0x99/255.0 blue:0xcc/255.0 alpha:1.0] };
  MGSwipeButton *likeButton = [MGSwipeButton buttonWithTitle:@"Like" backgroundColor:colors[0] padding:15];
  MGSwipeButton *unlikeButton = [MGSwipeButton buttonWithTitle:@"Unlike" backgroundColor:colors[1] padding:15];
  return @[likeButton, unlikeButton];
}

-(NSArray *)createRightButtons {
  UIColor *colors[2] = {[UIColor redColor], [UIColor lightGrayColor]};
  MGSwipeButton *deleteButton = [MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:colors[0] padding:15];
  MGSwipeButton *moreButton = [MGSwipeButton buttonWithTitle:@"More" backgroundColor:colors[1] padding:15];
  return @[deleteButton, moreButton];
}


#pragma mark - Navigation methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  DetailViewController *upcoming = segue.destinationViewController;
  if ([segue.identifier isEqualToString:@"viewArtist"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Artist *artist = self.artists[indexPath.row];
    upcoming.artist = artist;
  } else if ([segue.identifier isEqualToString:@"addArtist"]) {
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] init];
    cancel.title = @"Cancel";
    cancel.style = UIBarButtonItemStyleBordered;
    cancel.target = upcoming;
    cancel.action = @selector(cancelAdd);
    upcoming.navigationItem.leftBarButtonItem = cancel;
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] init];
    done.title = @"Done";
    done.style = UIBarButtonItemStyleBordered;
    done.target = upcoming;
    done.action = @selector(addNewArtist);
    upcoming.navigationItem.rightBarButtonItem = done;
  }
}

#pragma mark - Private helper methods

-(void)fetchAllArtists
{
  // Fetch `liked` artists with MagicalRecord, sorted by ascending name
  NSPredicate *liked = [NSPredicate predicateWithFormat:@"liked == YES"];
  self.artists = [[Artist findAllSortedBy:@"name" ascending:YES withPredicate:liked] mutableCopy];
}

-(void)saveContext
{
  [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
}

@end
