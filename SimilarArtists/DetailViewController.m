//
//  DetailViewController.m
//  SimilarArtists
//
//  Created by Jonathan Crossley on 8/29/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import "DetailViewController.h"
#import "SimilarViewController.h"
#import "LastfmAPIClient.h"
#import "Image.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface DetailViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@end

@implementation DetailViewController
            
#pragma mark - Managing the detail item

-(void)viewDidLoad {
    // 1. If there is no artist, create new Artist
    if (!self.artist) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Artist" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert textFieldAtIndex:0].returnKeyType = UIReturnKeyDone;
        [alert textFieldAtIndex:0].delegate = self;
        [alert show];
    }
    // 2. If we have an artist, but no details, fetch from API
    else if (!self.artist.mbid) {
        [self getArtist:self.artist.name];
    }
    
    // View setup
    // 3. Set the title, name, details field of the Artist
    self.title = self.artist.name ? self.artist.name : @"New Artist";
    self.artistDetailsView.text = self.artist.bio ? [self formatBio:self.artist.bio] : @"";
    self.artistDetailsView.editable = NO;
    
    // 4. If there is an image url, show it
    if (self.artist.images.count > 0) {
        // Image setup
        NSString *urlString = [[self.artist.images lastObject] text];
        [self.artistImage setImageWithURL:[NSURL URLWithString:urlString]];
    }
    
    // 5. Set delegates
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

#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SimilarViewController *upcoming = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"viewSimilar"]) {
        upcoming.artist = self.artist;
    }
}

#pragma mark - Private methods

-(void)saveArtistForResponse:(NSDictionary*)artistDict {
    if (!self.artist) {
        self.artist = [Artist createEntity];
    }
    
    self.artist.name = artistDict[@"name"];
    self.artist.mbid = artistDict[@"mbid"];
    self.artist.bio = artistDict[@"bio"][@"content"];
    
    if ([artistDict[@"image"] count] > 0) {
        Image *image = [Image createEntity];
        image.text = [artistDict[@"image"] lastObject][@"#text"];
        image.size = [artistDict[@"image"] lastObject][@"size"];
        image.artist = self.artist;
        
        [self.artist addImagesObject:image];
    }
    
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

#pragma mark - UITextFieldDelegate

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.length > 0) {
        self.title = textField.text;
        self.artist.name = textField.text;
    }
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // cancel?
    if (buttonIndex == 0) {
        [self cancelAdd];
    // ok
    } else if (buttonIndex == 1) {
        UITextField *field = [alertView textFieldAtIndex:0];
        [self getArtist:field.text];
    }
}

#pragma - Private helper methods

-(void)getArtist:(NSString*)artistName {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading artist";
    
    // get artist details
    LastfmAPIClient *api = [LastfmAPIClient sharedClient];
    [api getInfoForArtist:artistName autocorrect:YES
                  success:^(NSURLSessionDataTask *task, id responseObject) {
                      NSLog(@"Success -- %@", responseObject);
                      [hud hide:YES];
                      [self saveArtistForResponse:responseObject[@"artist"]];
                      
                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                      NSLog(@"Failure -- %@", error.description);
                      [hud hide:YES];
                  }];
}

-(void)refreshView {
    self.title = self.artist.name;
    self.artistDetailsView.text = [self formatBio:self.artist.bio];
    
    if (self.artist.images.count > 0) {
        NSString *url = [[self.artist.images lastObject] text];
        [self.artistImage setImageWithURL:[NSURL URLWithString:url]];
    }
}

-(NSString*)formatBio:(NSString*)htmlString {
    if (!htmlString) {
        return nil;
    }
    
    // strip html
    NSRange r;
    NSString *s = [htmlString copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    }
    
    // trim Creative Commons
    NSString *creativeCommons = @"User-contributed text is available under the Creative Commons By-SA License "
                                  "and may also be available under the GNU FDL.";
    s = [s stringByReplacingOccurrencesOfString:creativeCommons withString:@""];
    
    // replace occurances of &quot;
    s = [s stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    
    // remove "read more on last.fm"
    NSString *readMore = [NSString stringWithFormat:@"Read more about %@ on Last.fm.", self.artist.name];
    s = [s stringByReplacingOccurrencesOfString:readMore withString:@""];
    
    return [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
