//
//  MasterViewController.h
//  SimilarArtists
//
//  Created by Jonathan Crossley on 8/29/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MGSwipeTableCell/MGSwipeTableCell.h>

@interface ArtistsTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate>

@end

