//
//  ArtistsTableViewController.m
//  SimilarArtists
//
//  Created by Jonathan Crossley on 8/29/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchAllArtists];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor blackColor];
    [self.tableView registerClass:[ArtistCell class] forCellReuseIdentifier:@"Cell"];
}

#pragma mark - UITableViewDatasource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ArtistCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                            forIndexPath:indexPath];
    cell.artist = self.artists[indexPath.row];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.artists.count;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - UITableViewDelegate

-(void)  tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Deleting an Entity with MagicalRecord
        [self.artists[indexPath.row] deleteEntity];
        [self saveContext];
        [self.artists removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

#pragma mark - Navigation methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
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

-(void)fetchAllArtists {
    // Fetch entities with MagicalRecord, sorted by ascending name
    self.artists = [[Artist findAllSortedBy:@"name" ascending:YES] mutableCopy];
}

-(void)saveContext {
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
}

@end
