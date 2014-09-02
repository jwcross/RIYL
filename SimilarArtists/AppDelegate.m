//
//  AppDelegate.m
//  SimilarArtists
//
//  Created by Jonathan Crossley on 8/29/14.
//  Copyright (c) 2014 CCS. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailViewController.h"
#import "MasterViewController.h"
#import "Artist.h"
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>

@interface AppDelegate ()

@end

@implementation AppDelegate
            

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // Setup CoreData with MagicalRecord
    [MagicalRecord setupCoreDataStack];
    
    // Setup App with prefilled Artist items.
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"MR_HasPrefilledArtists"]) {
        // Create Nujabes
        Artist *nujabes = [Artist createEntity];
        nujabes.name = @"Nujabes";
        nujabes.mbid = @"1595addf-f76b-450a-a097-af852ff35f27";
        nujabes.url = @"http://www.last.fm/music/Nujabes";
        
        // Create Modest Mouse
        Artist *modestMouse = [Artist createEntity];
        modestMouse.name = @"Modest Mouse";
        modestMouse.mbid = @"a96ac800-bfcb-412a-8a63-0a98df600700";
        modestMouse.url = @"http://www.last.fm/music/Modest+Mouse";
        
        // Create Nightmares on Wax
        Artist *nightmaresOnWax = [Artist createEntity];
        nightmaresOnWax.name = @"Nightmares on Wax";
        nightmaresOnWax.mbid = @"b8c5cc4f-239f-4e02-b46f-b040b77c2030";
        nightmaresOnWax.url = @"http://www.last.fm/music/Nightmares+on+Wax";
        
        // Create Tokyo Police Club
        Artist *tokyoPoliceClub = [Artist createEntity];
        tokyoPoliceClub.name = @"Tokyo Police Club";
        tokyoPoliceClub.mbid = @"35a6a353-b186-4c13-a264-d18d5e2ce853";
        tokyoPoliceClub.url = @"http://www.last.fm/music/Tokyo+Police+Club";
        
        // Create Why?
        Artist *why = [Artist createEntity];
        why.name = @"Why?";
        why.mbid = @"5dc8a187-443d-4fb2-a0fc-209ef241b9ce";
        why.url = @"http://www.last.fm/music/Why%3F";
        
        // Create The Hotelier
        Artist *theHotelier = [Artist createEntity];
        theHotelier.name = @"The Hotelier";
        theHotelier.mbid = @"af63ec4d-9fe4-4001-bcb6-8dd160ee6451";
        theHotelier.url = @"http://www.last.fm/music/The+Hotelier";
        
        // Create Grouper
        Artist *grouper = [Artist createEntity];
        grouper.name = @"Grouper";
        grouper.mbid = @"7e571e09-887e-4544-b993-eb75e7837ec1";
        grouper.url = @"http://www.last.fm/music/Grouper";
        
        // Create Cass McCombs
        Artist *cassMccombs = [Artist createEntity];
        cassMccombs.name = @"Cass McCombs";
        cassMccombs.mbid = @"c213f661-70a8-42aa-b858-62f5bd2d72e9";
        cassMccombs.url = @"http://www.last.fm/music/Cass+McCombs";
        
        // Create Kanye West
        Artist *yeezus = [Artist createEntity];
        yeezus.name = @"Kanye West";
        yeezus.mbid = @"164f0d73-1234-4e2c-8743-d77bf2191051";
        yeezus.url = @"http://www.last.fm/music/Kanye+West";
        
        // Save Managed Object Context
        [[NSManagedObjectContext defaultContext] saveToPersistentStoreWithCompletion:nil];
        
        // Set User Default to prevent another preload of data on startup.
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MR_HasPrefilledArtists"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return YES;
}

@end
