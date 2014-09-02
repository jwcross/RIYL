//
//  DetailViewController.m
//  SimilarArtists
//
//  Created by Jonathan Crossley on 8/29/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import "DetailViewController.h"
#import "LastfmAPIClient.h"
#import "Image.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface DetailViewController ()

@end

@implementation DetailViewController
            
#pragma mark - Managing the detail item

-(void)viewDidLoad {
    // 1. If there is no artist, create new Artist
    if (!self.artist) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading artist";
        
        // get artist details
        [[LastfmAPIClient sharedClient] getInfoForArtist:@"Nujabes" autocorrect:YES
             success:^(NSURLSessionDataTask *task, id responseObject) {
                 NSLog(@"Success -- %@", responseObject);
                 [hud hide:YES];
                 [self saveArtistForResponse:responseObject[@"artist"]];
                 
             } failure:^(NSURLSessionDataTask *task, NSError *error) {
                 NSLog(@"Failure -- %@", error.description);
                 [hud hide:YES];
             }];
    }
    // 2. If there are no artist details, create new ArtistDetails
    // todo!
    
    // View setup
    // 3. Set the title, name, details field of the Artist
    self.title = self.artist.name ? self.artist.name : @"New Artist";
    self.artistNameField.text = self.artist.name;
    
    // 4. Set delegates
    self.artistNameField.delegate = self;
    self.artistDetailsView.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // Save context as view disappears.
    [self saveContext];
}

-(void)cancelAdd {
    [self.artist deleteEntity];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)addNewArtist {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private methods

-(void)saveArtistForResponse:(NSDictionary*)artistDict {
    Artist *newArtist = [Artist createEntity];
    newArtist.name = artistDict[@"name"];
    newArtist.mbid = artistDict[@"mbid"];
    
    if ([artistDict[@"image"] count] > 0) {
        Image *image = [Image createEntity];
        image.text = [artistDict[@"image"] lastObject][@"#text"];
        image.size = [artistDict[@"image"] lastObject][@"size"];
        image.artist = newArtist;
        
        [newArtist addImagesObject:image];
    }
    self.artist = newArtist;
    
    [self refreshView];
}

-(void)saveContext {
    [[NSManagedObjectContext defaultContext]
     saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
         if (success) {
             NSLog(@"Artist successfully saved.");
         } else if (error) {
             NSLog(@"Error saving artist: %@", error.description);
         }
    }];
}

-(IBAction)didFinishEditingArtist:(id)sender {
    [self.artistNameField resignFirstResponder];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.length > 0) {
        self.title = textField.text;
        self.artist.name = textField.text;
    }
}

#pragma - Private helper methods

-(void)refreshView {
    self.title = self.artist.name;
    self.artistNameField.text = self.artist.name;
    
    if (self.artist.images.count > 0) {
        NSString *url = [[self.artist.images lastObject] text];
        [self.artistImage setImageWithURL:[NSURL URLWithString:url]];
    }
}

@end
