//
//  SimilarViewController.h
//  SimilarArtists
//
//  Created by Jonathan Crossley on 9/3/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Artist.h"

@interface SimilarViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) Artist *artist;

@end
