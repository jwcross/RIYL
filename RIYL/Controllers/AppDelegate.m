#import "AppDelegate.h"
#import "DetailViewController.h"
#import "ArtistsTableViewController.h"
#import "Artist.h"
#import "Image.h"
#import "InitialDataHelper.h"
#import "UIColor+HexColors.h"
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <MagicalRecord/MagicalRecord+Options.h>

@implementation UIColor (Extensions)


@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor myDarkGrayColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    [self setupMagicalRecord];
    
    return YES;
}

-(void)setupMagicalRecord
{
    // Setup CoreData with MagicalRecord
    [MagicalRecord setupAutoMigratingCoreDataStack];
    
    // Define MagicalRecord logging level
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelWarn];
    
    // If necessary, initialize with sample Artist items.
    if ([[InitialDataHelper sharedInstance] hasPrefilledArtists] == NO) {
        [[InitialDataHelper sharedInstance] initializeData];
    }
}


@end
