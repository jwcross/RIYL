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
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <MagicalRecord/MagicalRecord+Options.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.tintColor = [UIColor whiteColor];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.22f green:0.17f blue:0.13f alpha:1.00f]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    [self setupMagicalRecord];
    
    return YES;
}

-(void)setupMagicalRecord {
    // Setup CoreData with MagicalRecord
    [MagicalRecord setupAutoMigratingCoreDataStack];
    
    // Define MagicalRecord logging level
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelWarn];
    
    // Setup App with prefilled Artist items.
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"MR_HasPrefilledArtists"]) {
        
        [self setupSampleData];
        
        // Save Managed Object Context
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
        
        // Set User Default to prevent another preload of data on startup.
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MR_HasPrefilledArtists"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

-(void)setupSampleData {
    NSString *url;
    
    // Create Nujabes
    Artist *nujabes = [Artist MR_createEntity];
    nujabes.name = @"Nujabes";
    nujabes.liked = @NO;
    nujabes.nowListening = @YES;
    url = @"http://userserve-ak.last.fm/serve/_/44041763/Nujabes+_.jpg";
    [nujabes addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create Modest Mouse
    Artist *modestMouse = [Artist MR_createEntity];
    modestMouse.liked = @NO;
    modestMouse.nowListening = @YES;
    modestMouse.name = @"Modest Mouse";
    url = @"http://userserve-ak.last.fm/serve/500/886281/Modest+Mouse.jpg";
    [modestMouse addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create Nightmares on Wax
    Artist *nightmaresOnWax = [Artist MR_createEntity];
    nightmaresOnWax.liked = @NO;
    nightmaresOnWax.nowListening = @YES;
    nightmaresOnWax.name = @"Nightmares on Wax";
    url = @"http://userserve-ak.last.fm/serve/_/2162189/Nightmares+on+Wax.jpg";
    [nightmaresOnWax addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create Tokyo Police Club
    Artist *tokyoPoliceClub = [Artist MR_createEntity];
    tokyoPoliceClub.liked = @NO;
    tokyoPoliceClub.nowListening = @YES;
    tokyoPoliceClub.name = @"Tokyo Police Club";
    url = @"http://userserve-ak.last.fm/serve/_/4855404/Tokyo+Police+Club+tokyopolice_cover.jpg";
    [tokyoPoliceClub addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create Why?
    Artist *why = [Artist MR_createEntity];
    why.liked = @NO;
    why.nowListening = @YES;
    why.name = @"Why?";
    url = @"http://userserve-ak.last.fm/serve/_/28744645/Why+Live+Dublab+Session+PROPER.png";
    [why addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create The Hotelier
    Artist *theHotelier = [Artist MR_createEntity];
    theHotelier.liked = @NO;
    theHotelier.nowListening = @YES;
    theHotelier.name = @"The Hotelier";
    url = @"http://userserve-ak.last.fm/serve/500/98412025/The+Hotelier+TheHotelier5.png";
    [theHotelier addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create Grouper
    Artist *grouper = [Artist MR_createEntity];
    grouper.liked = @NO;
    grouper.nowListening = @YES;
    grouper.name = @"Grouper";
    url = @"http://userserve-ak.last.fm/serve/_/69589066/Grouper+Liz6.jpg";
    [grouper addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create Cass McCombs
    Artist *cassMccombs = [Artist MR_createEntity];
    cassMccombs.liked = @NO;
    cassMccombs.nowListening = @YES;
    cassMccombs.name = @"Cass McCombs";
    url = @"http://userserve-ak.last.fm/serve/_/32726321/Cass+McCombs+CASS.jpg";
    [cassMccombs addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create Kanye West
    Artist *yeezus = [Artist MR_createEntity];
    yeezus.liked = @NO;
    yeezus.nowListening = @YES;
    yeezus.name = @"Kanye West";
    url = @"http://userserve-ak.last.fm/serve/500/91770519/Kanye+West+Yeezus+PNG.png";
    [yeezus addImagesObject:[Image createEntityWithUrl:url]];
}

@end
