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

typedef enum {
    Normal, AddArtist, ViewSimilar
} DetailMode;

@interface DetailViewController ()
<UITextFieldDelegate, UIAlertViewDelegate>
@property (nonatomic, assign) DetailMode mode;
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
        [alert textFieldAtIndex:0].delegate = self;
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
    self.artistDetailsView.editable = NO;
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
    
    // 5. Set delegates
    self.artistDetailsView.delegate = self;
    
    // 6. Refresh status bar
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
    self.mode = AddArtist;
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
    self.mode = ViewSimilar;
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
#pragma mark Actions

- (IBAction)readMoreAction:(id)sender
{
    UIAlertController *actionSheet = [self readIntegrationsSheetForArtist:self.artist];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (IBAction)openArtistAction:(id)sender
{
    UIAlertController *actionSheet = [self integrationsSheetForArtist:self.artist];
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
    // cancel
    if (buttonIndex == 0) {
        [[alertView textFieldAtIndex:0] endEditing:YES];
        [self cancelAdd];
    // ok
    } else if (buttonIndex == 1) {
        NSString *name = [alertView textFieldAtIndex:0].text;
        [self getArtist:name];
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
                      
                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                      NSLog(@"Failure -- %@", error.description);
                      [hud hide:YES];
                  }];
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

- (void)refreshAddArtistButton
{
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
    UIColor *tintColor = [colorArt.backgroundColor colorWithAlphaComponent:0.7f];
    UIImage *blurImage = [image applyBlurWithRadius:15
                                          tintColor:tintColor
                              saturationDeltaFactor:1.8f
                                          maskImage:nil];
    self.backgroundImageView.image = blurImage;
    
    // set artist text color: see http://stackoverflow.com/a/19168661
    self.artistDetailsView.editable = YES;
    self.artistDetailsView.textColor = [self primaryTextColorForImage:image
                                                             colorArt:colorArt];
    self.artistDetailsView.editable = NO;
    
    // set detail colors
    [self.readMoreButton setTitleColor:colorArt.primaryColor forState:UIControlStateNormal];
    [self.openInButton setTitleColor:colorArt.primaryColor forState:UIControlStateNormal];
    [self.addToMyArtistsButton setTitleColor:colorArt.primaryColor forState:UIControlStateNormal];
    
    // set button highlighted colors
    self.openInButton.highlightColor = [colorArt.secondaryColor colorWithAlphaComponent:0.3f];
    self.readMoreButton.highlightColor = [colorArt.secondaryColor colorWithAlphaComponent:0.3f];
    self.addToMyArtistsButton.highlightColor = [colorArt.secondaryColor colorWithAlphaComponent:0.3f];
    
    // set color of dividers
    [self.divider1 setBackgroundColor:[colorArt.secondaryColor colorWithAlphaComponent:0.3f]];
    [self.divider2 setBackgroundColor:[colorArt.secondaryColor colorWithAlphaComponent:0.3f]];
    [self.divider3 setBackgroundColor:[colorArt.secondaryColor colorWithAlphaComponent:0.3f]];
    
    // colorize status bar
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
    SLColorArt *colorArt = [self.artistImage.image colorArt];
    
    CGFloat R, G, B, A;
    [colorArt.backgroundColor getRed:&R green:&G blue:&B alpha:&A];
    
    // http://stackoverflow.com/a/2509596
    // BOOL darkText = (R*299 + G*587 + B*114) > 500;
    
    // Copied from SLColorArt.m
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
    UIColor *background = colorArt.backgroundColor;
    
    if ([colorArt.primaryColor isLegibleAgainst:background]) {
        return colorArt.primaryColor;
        
    } else if ([colorArt.secondaryColor isLegibleAgainst:background]) {
        return colorArt.secondaryColor;
        
    } else if ([colorArt.detailColor isLegibleAgainst:background]) {
        return colorArt.detailColor;
        
    } else if ([self preferredStatusBarStyle] == UIStatusBarStyleDefault) {
        UIColor *darker = [colorArt.primaryColor darken];
        BOOL legible = [darker isLegibleAgainst:background];
        return legible ? darker : [UIColor blackColor];
        
    } else {
        UIColor *lighter = [colorArt.primaryColor lighten];
        BOOL legible = [lighter isLegibleAgainst:background];
        return legible ? lighter : [UIColor whiteColor];
    }
}

#pragma mark -
#pragma mark Dividers

- (void)initShowHideDividersOnButtonEvents
{
    UIControlEvents hideEvents = UIControlEventTouchDown;
    UIControlEvents showEvents = UIControlEventTouchDragExit | UIControlEventTouchUpInside;
    
    // hide dividers when buttons touched
    [self.readMoreButton addTarget:self
                            action:@selector(hideDivider1)
                  forControlEvents:hideEvents];
    [self.openInButton addTarget:self
                          action:@selector(hideDivider1)
                forControlEvents:hideEvents];
    [self.openInButton addTarget:self
                          action:@selector(hideDivider2)
                forControlEvents:hideEvents];
    [self.addToMyArtistsButton addTarget:self
                                  action:@selector(hideDivider2)
                        forControlEvents:hideEvents];
    [self.addToMyArtistsButton addTarget:self
                                  action:@selector(hideDivider3)
                        forControlEvents:hideEvents];
    
    // clear highlight when buttons released
    [self.readMoreButton addTarget:self
                            action:@selector(showDivider1)
                  forControlEvents:showEvents];
    [self.openInButton addTarget:self
                          action:@selector(showDivider1)
                forControlEvents:showEvents];
    [self.openInButton addTarget:self
                          action:@selector(showDivider2)
                forControlEvents:showEvents];
    [self.addToMyArtistsButton addTarget:self
                                  action:@selector(showDivider2)
                        forControlEvents:showEvents];
    [self.addToMyArtistsButton addTarget:self
                                  action:@selector(showDivider3)
                        forControlEvents:showEvents];
}

- (void)hideDivider1
{
    self.divider1.hidden = YES;
}

- (void)hideDivider2
{
    self.divider2.hidden = YES;
}

- (void)hideDivider3
{
    self.divider3.hidden = YES;
}

- (void)showDivider1
{
    self.divider1.hidden = NO;
}

- (void)showDivider2
{
    self.divider2.hidden = NO;
}

- (void)showDivider3
{
    self.divider3.hidden = NO;
}

@end
