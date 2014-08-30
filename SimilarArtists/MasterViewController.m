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

@interface MasterViewController ()

@end

@implementation MasterViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:nil];
    self.navigationItem.rightBarButtonItem = addButton;
    
    LastfmAPIClient *client = [LastfmAPIClient sharedClient];
    [client getSimilarArtistsForArtist:@"Nujabes" limit:20 autocorrect:YES
                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                   NSLog(@"Success -- %@", responseObject);
                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   NSLog(@"Failure -- %@", error);
                               }];
}

@end
