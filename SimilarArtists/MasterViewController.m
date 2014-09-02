//
//  MasterViewController.m
//  SimilarArtists
//
//  Created by Jonathan Crossley on 8/29/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "LastfmAPIClient.h"
#import "Artist.h"

@interface MasterViewController ()
@property NSMutableArray *artists;
@end

@implementation MasterViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchAllArtists];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // edit button
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    // add button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                              target:self action:nil];
    
//    LastfmAPIClient *client = [LastfmAPIClient sharedClient];
//    [client getSimilarArtistsForArtist:@"Nujabes" limit:20 autocorrect:YES
//                               success:^(NSURLSessionDataTask *task, id responseObject) {
//                                   NSLog(@"Success -- %@", responseObject);
//                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
//                                   NSLog(@"Failure -- %@", error);
//                               }];
}

#pragma mark - UITableViewDatasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.artists.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                            forIndexPath:indexPath];
    // configure cell
    Artist *artist = self.artists[indexPath.row];
    cell.textLabel.text = artist.name;
    
    return cell;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Artist *artistToRemove = self.artists[indexPath.row];
        /* todo! Remove Image from local documents
        if (artistToRemove.artistDetails.image) {
            [ImageSaver deleteImageAtPath:artistToRemove.artistDetails.image];
        } */
        // Deleting an Entity with MagicalRecord
        [artistToRemove deleteEntity];
        [self saveContext];
        [self.artists removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
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
