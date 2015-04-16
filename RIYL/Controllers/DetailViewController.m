#import "DetailViewController.h"
#import "SimilarViewController.h"
#import "LastfmAPIClient.h"
#import "Image.h"
#import "UIImage+ImageEffects.h"
#import "UIColor+Util.h"
#import "NSString+LastFm.h"
#import "UIViewController+Integrations.h"
#import "NSAttributedString+Underline.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <SpinKit/RTSpinKitView.h>
#import <libextobjc/EXTScope.h>
#import <ColorArt/UIImage+ColorArt.h>

@interface DetailViewController () <UIAlertViewDelegate>
@end

@implementation DetailViewController
            
#pragma mark - 
#pragma mark Managing the detail item

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 1. If there is no artist, show Alert to create new artist
    if (!self.artist) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Artist"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
     
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert textFieldAtIndex:0].returnKeyType = UIReturnKeyDone;
        [alert show];
    }
    // 2. If we have an artist, but no details, fetch from API
    else if (!self.artist.mbid || !self.artist.bio) {
        [self getArtist:self.artist.name];
    }
    
    // View setup
    // 3. Set the title, name, details field of the Artist
    self.title = self.artist.name ? self.artist.name : @"New Artist";
    self.artistDetailsView.text = ({
        NSString *artist = self.artist.name;
        self.artist.bio ? [self.artist.bio formatBioWithArtist:artist] : @"";
    });
    [self refreshAddToMyArtistsButton];
    [self refreshReadMoreLabel];
    [self refreshOpenInLabel];
    [self initShowHideDividersOnButtonEvents];
    
    // 4. If there is an image url, show it
    NSString *imageUrl = [self.artist.images.firstObject text];
    if (imageUrl) {
        // Image setup
        [self configureViewWithImageURL:[NSURL URLWithString:imageUrl]];
    }
    
    // 5. Refresh status bar
    [self refreshStatusBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshNavigationBar];
    [self refreshStatusBar];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // Save context as view disappears.
    [self saveContext];
}

- (void)prepareForAddArtist
{
    self.navigationItem.leftBarButtonItem = ({
        UIBarButtonItem *cancel = [[UIBarButtonItem alloc] init];
        cancel.title = @"Cancel";
        cancel.style = UIBarButtonItemStylePlain;
        cancel.target = self;
        cancel.action = @selector(cancelAdd);
        cancel;
    });
    
    self.navigationItem.rightBarButtonItem = ({
        UIBarButtonItem *done = [[UIBarButtonItem alloc] init];
        done.title = @"Done";
        done.style = UIBarButtonItemStylePlain;
        done.target = self;
        done.action = @selector(addNewArtist);
        done;
    });
}

- (void)prepareForSimilarArtist
{
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)cancelAdd
{
    self.artist.nowListening = @NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addNewArtist
{
    self.artist.nowListening = @YES;
    [self saveContext];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark IBActions

- (IBAction)readMoreAction:(id)sender
{
    UIAlertController *actionSheet = [self readIntegrationsSheetForArtist:self.artist];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (IBAction)openArtistAction:(id)sender
{
    UIAlertController *actionSheet = [self listenIntegrationsSheetForArtist:self.artist];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (IBAction)addArtistAction:(id)sender
{
    [self addNewArtist];
}

#pragma mark -
#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    SimilarViewController *upcoming = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"viewSimilar"]) {
        upcoming.artist = self.artist;
    }
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField *textField = [alertView textFieldAtIndex:0];
    
    if (buttonIndex == 0) { // Cancel
        [textField endEditing:YES];
        [self cancelAdd];
    } else if (buttonIndex == 1) { // OK
        [self getArtist:textField.text];
    }
}

#pragma mark - 
#pragma mark Private helper methods

- (void)saveArtistForResponse:(NSDictionary*)artistDict
{
    if (!self.artist) {
        NSString *name = artistDict[@"name"];
        self.artist = [Artist MR_findFirstOrCreateByAttribute:@"name" withValue:name];
    }
    
    self.artist.name = artistDict[@"name"];
    self.artist.mbid = artistDict[@"mbid"];
    self.artist.bio = artistDict[@"bio"][@"content"];
    
    // save highest-resolution image
    if ([artistDict[@"image"] count] > 0) {
        Image *image = [Image MR_createEntity];
        image.text = [artistDict[@"image"] lastObject][@"#text"];
        image.size = [artistDict[@"image"] lastObject][@"size"];
        image.artist = self.artist;
        [self.artist addImagesObject:image];
    }
}

- (void)saveContext
{
    [[NSManagedObjectContext MR_defaultContext]
     MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
         if (success) {
             NSLog(@"Artist successfully saved.");
         } else if (error) {
             NSLog(@"Error saving artist: %@", error.description);
         }
     }];
}

- (void)getArtist:(NSString*)artistName
{
    if ([self hasSavedArtist:artistName]) {
        NSPredicate *p = [NSPredicate predicateWithFormat:@"name ==[c] %@", artistName];
        self.artist = [Artist MR_findFirstWithPredicate:p];
        [self refreshView];
    }
    
    if (self.artist.bio) {
        NSLog(@"Already have details for this artist - returning early");
        self.artist.nowListening = @YES;
        return;
    }

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    RTSpinKitView *spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWave
                                                            color:[UIColor whiteColor]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = spinner;
    hud.labelText = NSLocalizedString(@"Loading artist", @"Loading artist");
    [spinner startAnimating];

    // get artist details
    @weakify(self)
    LastfmAPIClient *api = [LastfmAPIClient sharedClient];
    [api getInfoForArtist:artistName
              autocorrect:YES
                  success:^(NSURLSessionDataTask *task, id responseObject) {
                      @strongify(self)
                      NSLog(@"Success -- %@", responseObject);
                      [self handleArtistResponse:responseObject];
                      
                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                      NSLog(@"Failure -- %@", error.description);
                      [hud hide:YES];
                  }];
}

- (void)handleArtistResponse:(id)responseObject
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    
    // Check if response was successful, but returned error object
    if ([self artistNotFound:responseObject]) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"Artist Not Found", @"Artist Not Found");
        return;
        
    // Otherwise, save artist and update UI
    } else {
        [hud hide:YES];
        [self saveArtistForResponse:responseObject[@"artist"]];
        [self refreshView];
    }
}

- (BOOL)artistNotFound:(id)responseObject
{
    return [responseObject isKindOfClass:[NSDictionary class]]
        && [responseObject[@"error"] isEqualToNumber:@6];
}

- (BOOL)hasSavedArtist:(NSString*)artistName
{
    NSPredicate *p = [NSPredicate predicateWithFormat:@"name ==[c] %@", artistName];
    return [Artist MR_findFirstWithPredicate:p] != nil;
}

- (void)refreshView
{
    self.title = self.artist.name;
    self.artistDetailsView.text = [self.artist.bio formatBioWithArtist:self.artist.name];
    [self refreshReadMoreLabel];
    [self refreshOpenInLabel];
    [self refreshAddToMyArtistsButton];
    
    self.readMoreButton.hidden = NO;
    
    if (self.artist.images.count > 0) {
        NSString *url = [[self.artist.images firstObject] text];
        [self configureViewWithImageURL:[NSURL URLWithString:url]];
    }
}

- (void)refreshAddToMyArtistsButton
{
    BOOL userAlreadyHasArtist = [self.artist.nowListening isEqual:@YES];
    
    self.addToMyArtistsButton.hidden = !self.artist.bio || userAlreadyHasArtist;
    self.divider3.hidden = !self.artist.bio || userAlreadyHasArtist;
    
    if (!userAlreadyHasArtist) {
        NSString *format = @"Add %@ to My Artists";
        NSString *title = [NSString stringWithFormat:format, self.artist.name];
        [self.addToMyArtistsButton setTitle:title forState:UIControlStateNormal];
    }
}

- (void)refreshReadMoreLabel
{
    self.readMoreButton.hidden = !self.artist.name;
    
    if (!self.artist.bio) {
        [self.readMoreButton setTitle:@"" forState:UIControlStateNormal];
        self.divider1.hidden = YES;
    } else {
        self.divider1.hidden = NO;
        NSString *format = @"Read more about %@";
        NSString *readMore = [NSString stringWithFormat:format, self.artist.name];
        [self.readMoreButton setTitle:readMore forState:UIControlStateNormal];
    }
}

- (void)refreshOpenInLabel
{
    self.openInButton.hidden = !self.artist.name;
    
    if (!self.artist.bio) {
        [self.openInButton setTitle:@"" forState:UIControlStateNormal];
        self.divider2.hidden = YES;
    } else {
        self.divider2.hidden = NO;
        NSString *format = @"Listen to %@";
        NSString *title = [NSString stringWithFormat:format, self.artist.name];
        [self.openInButton setTitle:title forState:UIControlStateNormal];
    }
}

# pragma mark - LEColorPicker

typedef void (^ImageSuccess)(NSURLRequest*, NSHTTPURLResponse*, UIImage*);
typedef void (^ImageError)(NSURLRequest*, NSHTTPURLResponse*, NSError*);

- (void)configureViewWithImageURL:(NSURL *)imageUrl
{
    // Define callbacks
    @weakify(self)
    ImageSuccess success = ^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        @strongify(self)
        self.artistImage.image = image;
        [self colorizeForImage:image];
    };
    ImageError failure = ^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error){
        NSLog(@"Error fetching artist image");
    };
    
    // Fetch artist image and clear spinner on success
    [self.artistImage setImageWithURLRequest:[NSURLRequest requestWithURL:imageUrl]
                            placeholderImage:nil
                                     success:success
                                     failure:failure];
}

- (void)colorizeForImage:(UIImage *)image
{
    SLColorArt *colorArt = [image colorArt];
    
    // set blurred background image
    self.backgroundImageView.image = ({
        [image applyBlurWithRadius:15.f
                         tintColor:[colorArt.backgroundColor colorWithAlphaComponent:0.7f]
             saturationDeltaFactor:1.8f
                         maskImage:nil];
    });
    
    // set artist textColor via workaround: http://stackoverflow.com/a/19168661
    self.artistDetailsView.editable = YES;
    self.artistDetailsView.textColor = [self primaryTextColorForImage:image colorArt:colorArt];
    self.artistDetailsView.editable = NO;
    
    // set detail colors
    [self.readMoreButton setTitleColor:colorArt.primaryColor forState:UIControlStateNormal];
    [self.openInButton setTitleColor:colorArt.primaryColor forState:UIControlStateNormal];
    [self.addToMyArtistsButton setTitleColor:colorArt.primaryColor forState:UIControlStateNormal];
    
    // set button highlight and dividers
    UIColor *lightSecondary = [colorArt.secondaryColor colorWithAlphaComponent:0.3f];
    self.openInButton.highlightColor = lightSecondary;
    self.readMoreButton.highlightColor = lightSecondary;
    self.addToMyArtistsButton.highlightColor = lightSecondary;
    self.divider1.backgroundColor = lightSecondary;
    self.divider2.backgroundColor = lightSecondary;
    self.divider3.backgroundColor = lightSecondary;
    
    // colorize navigation and status bars
    [self refreshNavigationBar];
    [self refreshStatusBar];
}

- (void)refreshNavigationBar
{
    if (!self.artistImage.image) {
        return;
    }
    SLColorArt *colorArt = [self.artistImage.image colorArt];
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.barTintColor = colorArt.backgroundColor;
    navigationBar.tintColor = colorArt.secondaryColor;
    navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : colorArt.primaryColor};
}

- (void)refreshStatusBar
{
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    if ([self preferredStatusBarStyle] == UIStatusBarStyleLightContent) {
        navigationBar.barStyle = UIBarStyleBlack;
    } else {
        navigationBar.barStyle = UIBarStyleDefault;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (!self.artistImage.image) {
        return UIStatusBarStyleLightContent;
    }
    
    // Adapted from SLColorArt.m
    SLColorArt *colorArt = [self.artistImage.image colorArt];
    CGFloat R, G, B, A;
    [colorArt.backgroundColor getRed:&R green:&G blue:&B alpha:&A];
    
    BOOL darkText = (0.2126*R + 0.7152*G + 0.0722*B) > 0.5;
    return darkText ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}

#pragma mark -
#pragma mark Contrasting Colors

- (UIColor *)primaryTextColorForImage:(UIImage *)artistImage
                             colorArt:(SLColorArt *)colorArt
{
    if (!colorArt) {
        colorArt = [artistImage colorArt];
    }
    NSArray *colorsToTry = @[colorArt.primaryColor,
                             colorArt.secondaryColor,
                             colorArt.detailColor,
                             [colorArt.primaryColor darken],
                             [colorArt.primaryColor lighten]];
    UIColor *background = colorArt.backgroundColor;
    
    for (UIColor *color in colorsToTry) {
        if ([color isLegibleAgainst:background]) {
            return color;
        }
    }
    
    if ([self preferredStatusBarStyle] == UIStatusBarStyleDefault) {
        return [UIColor blackColor];
    } else {
        return [UIColor whiteColor];
    }
}

#pragma mark -
#pragma mark Dividers

- (void)initShowHideDividersOnButtonEvents
{
    UIControlEvents hideEvents = UIControlEventTouchDown;
    UIControlEvents showEvents = UIControlEventTouchDragExit | UIControlEventTouchUpInside;
    
    // show and hide dividers when buttons touched
    NSArray *buttons = @[self.readMoreButton, self.openInButton, self.addToMyArtistsButton];
    
    for (UIButton *button in buttons) {
        [button addTarget:self action:@selector(hideDividers) forControlEvents:hideEvents];
        [button addTarget:self action:@selector(showDividers) forControlEvents:showEvents];
    }
}

- (void)hideDividers
{
    if (self.readMoreButton.isTouchInside) {
        self.divider1.hidden = YES;
    }
    if (self.openInButton.isTouchInside) {
        self.divider1.hidden = YES;
        self.divider2.hidden = YES;
    }
    if (self.addToMyArtistsButton.isTouchInside) {
        self.divider2.hidden = YES;
        self.divider3.hidden = YES;
    }
}

- (void)showDividers
{
    if (!self.readMoreButton.isHidden) {
        self.divider1.hidden = NO;
    }
    if (!self.openInButton.isHidden) {
        self.divider2.hidden = NO;
    }
    if (!self.addToMyArtistsButton.isHidden) {
        self.divider3.hidden = NO;
    }
}

@end
