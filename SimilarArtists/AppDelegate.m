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
        
        // Create Modest Mouse
        Artist *modestMouse = [Artist createEntity];
        modestMouse.name = @"Modest Mouse";
        
        // Create Nightmares on Wax
        Artist *nightmaresOnWax = [Artist createEntity];
        nightmaresOnWax.name = @"Nightmares on Wax";
        
        // Create Tokyo Police Club
        Artist *tokyoPoliceClub = [Artist createEntity];
        tokyoPoliceClub.name = @"Tokyo Police Club";
        
        // Create Why?
        Artist *why = [Artist createEntity];
        why.name = @"Why?";
        
        // Create The Hotelier
        Artist *theHotelier = [Artist createEntity];
        theHotelier.name = @"The Hotelier";
        
        // Create Grouper
        Artist *grouper = [Artist createEntity];
        grouper.name = @"Grouper";
        
        // Create Cass McCombs
        Artist *cassMccombs = [Artist createEntity];
        cassMccombs.name = @"Cass McCombs";
        
        // Create Kanye West
        Artist *yeezus = [Artist createEntity];
        yeezus.name = @"Kanye West";
        
        // Save Managed Object Context
        [[NSManagedObjectContext defaultContext] saveToPersistentStoreWithCompletion:nil];
        
        // Set User Default to prevent another preload of data on startup.
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MR_HasPrefilledArtists"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return YES;
}

@end
