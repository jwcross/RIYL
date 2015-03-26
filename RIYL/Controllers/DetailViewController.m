#import "DetailViewController.h"
#import "SimilarViewController.h"
#import "LastfmAPIClient.h"
#import "Image.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <SpinKit/RTSpinKitView.h>
#import <libextobjc/EXTScope.h>
#import <ColorArt/UIImage+ColorArt.h>

typedef enum {
    Normal, AddArtist, ViewSimilar
} DetailMode;

@interface DetailViewController () <UITextFieldDelegate, UIAlertViewDelegate>
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
    self.artistDetailsView.text = self.artist.bio ? [self formatBio:self.artist.bio] : @"";
    self.artistDetailsView.editable = NO;
    
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
    [self.artist MR_deleteEntity];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addNewArtist
{
    [self.navigationController popViewControllerAnimated:YES];
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
#pragma mark UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length > 0) {
        self.title = textField.text;
        self.artist.name = textField.text;
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
    
    // default `now listening` for added artists, except when launched from Similar
    if (self.mode != ViewSimilar) {
        self.artist.nowListening = @YES;
    }
    if (!self.artist.liked) {
      self.artist.liked = @NO; // default not-`liked` for added artists
    }
  
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
        self.artist = [Artist MR_findFirstByAttribute:@"name" withValue:artistName];
        [self refreshView];
    }
    
    if (self.artist.bio) {
        NSLog(@"Already have details for this artist - returning early");
        return;
    }

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    RTSpinKitView *spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWave color:[UIColor whiteColor]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = spinner;
    hud.labelText = NSLocalizedString(@"Loading artist", @"Loading artist");
    [spinner startAnimating];

    // get artist details
    LastfmAPIClient *api = [LastfmAPIClient sharedClient];
    [api getInfoForArtist:artistName autocorrect:YES
                  success:^(NSURLSessionDataTask *task, id responseObject) {
                      NSLog(@"Success -- %@", responseObject);
                      [hud hide:YES];
                      [self saveArtistForResponse:responseObject[@"artist"]];
                      [self refreshView];
                      
                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                      NSLog(@"Failure -- %@", error.description);
                      [hud hide:YES];
                  }];
}

- (BOOL)hasSavedArtist:(NSString*)artistName
{
    return [Artist MR_findByAttribute:@"name" withValue:artistName] != nil;
}

- (void)refreshView
{
    self.title = self.artist.name;
    self.artistDetailsView.text = [self formatBio:self.artist.bio];
    
    if (self.artist.images.count > 0) {
        NSString *url = [[self.artist.images firstObject] text];
        [self configureViewWithImageURL:[NSURL URLWithString:url]];
    }
}

- (NSString*)formatBio:(NSString*)htmlString
{
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
    NSString *creativeCommons = @"User-contributed text is available under the Creative Commons "
        "By-SA License and may also be available under the GNU FDL.";
    s = [s stringByReplacingOccurrencesOfString:creativeCommons withString:@""];
    
    // replace occurances of &quot;
    s = [s stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    
    // remove "read more on last.fm"
    NSString *readMore = [NSString stringWithFormat:@"Read more about %@ on Last.fm.", self.artist.name];
    s = [s stringByReplacingOccurrencesOfString:readMore withString:@""];
    
    return [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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
    
    self.view.backgroundColor = colorArt.backgroundColor;
    self.artistDetailsView.textColor = colorArt.secondaryColor;
    self.acknowledgementsLabel.textColor = colorArt.detailColor;
    
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
    
    // http://stackoverflow.com/a/2509596
    SLColorArt *colorArt = [self.artistImage.image colorArt];
    const CGFloat * components = CGColorGetComponents(colorArt.backgroundColor.CGColor);
    CGFloat R = components[0], G = components[1], B = components[2];
    BOOL darkText = (R*299 + G*587 + B*114) > 250;
    return darkText ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}

@end
