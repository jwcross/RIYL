//
//  AppDelegate.m
//  SimilarArtists
//
//  Created by Jonathan Crossley on 8/29/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailViewController.h"
#import "ArtistsTableViewController.h"
#import "Artist.h"
#import "Image.h"
#import "InitialDataHelper.h"
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <MagicalRecord/MagicalRecord+Options.h>

@implementation UIColor (Extensions)

+ (UIColor*)colorWithHexString:(NSString*)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0
                           green:((rgbValue & 0xFF00) >> 8)/255.0
                            blue:(rgbValue & 0xFF)/255.0
                           alpha:1.0];
}

+ (UIColor*)darkerGrayColor {
    return [UIColor colorWithHexString:@"#373c42"];
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor darkerGrayColor]];
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
