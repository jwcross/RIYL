//
//  DetailViewController.h
//  SimilarArtists
//
//  Created by Jonathan Crossley on 8/29/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Artist.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) Artist *artist;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

-(void)cancelAdd;
-(void)addNewArtist;

@end

