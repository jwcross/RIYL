//
//  DetailViewController.m
//  SimilarArtists
//
//  Created by Jonathan Crossley on 8/29/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController
            
#pragma mark - Managing the detail item

-(void)viewDidLoad {
    // 1. If there is no artist, create new Artist
    if (!self.artist) {
        self.artist = [Artist createEntity];
        [self.artistNameField becomeFirstResponder];
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

@end
