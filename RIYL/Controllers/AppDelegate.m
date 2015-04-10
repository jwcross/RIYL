#import "AppDelegate.h"
#import "InitialDataHelper.h"
#import "UIColor+HexColors.h"
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <MagicalRecord/MagicalRecord+Options.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].barTintColor = [UIColor myDarkGrayColor];
    [UINavigationBar appearance].titleTextAttributes = ({
        @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    });
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // Increase cache size
    [[NSURLCache sharedURLCache] setMemoryCapacity:(100*1024*1024)];
    [[NSURLCache sharedURLCache] setDiskCapacity:(200*1024*1024)];
    
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
    InitialDataHelper *dataHelper = [InitialDataHelper sharedInstance];
    if ([dataHelper hasPrefilledArtists] == NO) {
        [dataHelper initializeData];
    }
}


@end
