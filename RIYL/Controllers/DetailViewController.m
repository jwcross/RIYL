#import "DetailViewController.h"
#import "SimilarViewController.h"
#import "LastfmAPIClient.h"
#import "Image.h"
#import "UIImage+ImageEffects.h"
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
    self.artistDetailsView.text = self.artist.bio ? [self formatBio:self.artist.bio] : @"";
    self.artistDetailsView.editable = NO;
    self.readMoreLabel.hidden = !self.artist.name;
    self.acknowledgementsLabel.hidden = !self.artist.name;
    self.readMoreLabel.text = [NSString stringWithFormat:@"Read more about %@ on Last.fm", self.artist.name];
    
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
#pragma mark Actions

- (IBAction)readMoreAction:(id)sender
{
    NSLog(@"Read more clicked");
    NSString *name = [self.artist.name stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *urlString = [NSString stringWithFormat:@"http://www.last.fm/music/%@", name];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
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
    self.readMoreLabel.text = [NSString stringWithFormat:@"Read more about %@ on Last.fm", self.artist.name];
    
    self.acknowledgementsLabel.hidden = NO;
    self.readMoreLabel.hidden = NO;
    
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
    
    // replace occurrences of &quot;
    s = [s stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    
    // replace occurrences of %amp;
    s = [s stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    
    // remove "read more on last.fm"
    NSString *readMore = [NSString stringWithFormat:@"Read more about %@ on Last.fm.", self.artist.name];
    s = [s stringByReplacingOccurrencesOfString:readMore withString:@""];
    
    // remove "artist on last.fm"
    readMore = [NSString stringWithFormat:@"%@ on Last.fm.", self.artist.name];
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
    
    // background
    UIColor *tintColor = [colorArt.backgroundColor colorWithAlphaComponent:0.7f];
    UIImage *blurImage = [image applyBlurWithRadius:15
                                          tintColor:tintColor
                              saturationDeltaFactor:1.8f
                                          maskImage:nil];
    self.backgroundImageView.image = blurImage;
    
    self.artistDetailsView.textColor = [self primaryTextColorForImage:image colorArt:colorArt];
    self.readMoreLabel.textColor = colorArt.secondaryColor;
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
    
    SLColorArt *colorArt = [self.artistImage.image colorArt];
    const CGFloat * components = CGColorGetComponents(colorArt.backgroundColor.CGColor);
    CGFloat R = components[0], G = components[1], B = components[2];
    
    // http://stackoverflow.com/a/2509596
    // BOOL darkText = (R*299 + G*587 + B*114) > 500;
    
    // Copied from SLColorArt.m
    BOOL darkText = (0.2126*R + 0.7152*G + 0.0722*B) > 0.5;
    
    return darkText ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
    
}

#pragma mark -
#pragma mark Contrasting Colors
// TODO: Split out into a category on UIColor

- (UIColor *)primaryTextColorForImage:(UIImage *)artistImage
                             colorArt:(SLColorArt *)colorArt
{
    if (!colorArt) {
        colorArt = [artistImage colorArt];
    }
    UIColor *background = colorArt.backgroundColor;
    
    if ([self isLegible:colorArt.primaryColor onBackground:background]) {
        return colorArt.primaryColor;
        
    } else if ([self isLegible:colorArt.secondaryColor onBackground:background]) {
        return colorArt.secondaryColor;
        
    } else if ([self isLegible:colorArt.detailColor onBackground:background]) {
        return colorArt.detailColor;
        
    } else if ([self preferredStatusBarStyle] == UIStatusBarStyleDefault) {
        
        UIColor *darkerPrimary = [self darkenColor:colorArt.primaryColor];
        BOOL legible = [self isLegible:darkerPrimary onBackground:background];
        return legible ? darkerPrimary : [UIColor blackColor];
        
    } else {
        UIColor *lighterPrimary = [self lightenColor:colorArt.primaryColor];
        BOOL legible = [self isLegible:lighterPrimary onBackground:background];
        return legible ? lighterPrimary : [UIColor whiteColor];
    }
}

- (BOOL)isLegible:(UIColor *)foregroundColor onBackground:(UIColor *)backgroundColor
{
    CGFloat brightness = ABS([self brightness:foregroundColor] - [self brightness:backgroundColor]);
    CGFloat difference = [self colorDifference:foregroundColor against:backgroundColor];
    return brightness > 125 && difference > 400;
}

- (CGFloat)brightness:(UIColor *)color
{
    const CGFloat * components = CGColorGetComponents(color.CGColor);
    CGFloat R = components[0], G = components[1], B = components[2];
    return 299*R + 587*G + 114*B;
}

- (CGFloat)colorDifference:(UIColor *)color1 against:(UIColor *)color2
{
    const CGFloat * components = CGColorGetComponents(color1.CGColor);
    CGFloat R1 = components[0], G1 = components[1], B1 = components[2];
    
    components = CGColorGetComponents(color2.CGColor);
    CGFloat R2 = components[0], G2 = components[1], B2 = components[2];
    
    return 256*(MAX(R1,R2) + MAX(B1,B2) + MAX(G1,G2)) - 256*(MIN(R1,R2) + MIN(B1,B2) + MIN(G1,G2));
}

- (UIColor *)darkenColor:(UIColor *)color
{
    const CGFloat * components = CGColorGetComponents(color.CGColor);
    CGFloat R = components[0], G = components[1], B = components[2];
    
    CGFloat adjust = 0.10;
    return [UIColor colorWithRed:R*adjust green:G*adjust blue:B*adjust alpha:1];
}

- (UIColor *)lightenColor:(UIColor *)color
{
    const CGFloat * components = CGColorGetComponents(color.CGColor);
    CGFloat R = components[0], G = components[1], B = components[2];
    
    CGFloat adjust = 0.90;
    return [UIColor colorWithRed:(R+adjust*(1-R)) green:(G+adjust*(1-G)) blue:(B+adjust*(1-B)) alpha:1];
}

@end
