#import "InitialDataHelper.h"
#import "Image.h"
#import "Artist.h"

@implementation InitialDataHelper

+ (InitialDataHelper *)sharedInstance {
    static InitialDataHelper *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] init];
    });
    return _sharedClient;
}

- (BOOL)hasPrefilledArtists {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"MR_HasPrefilledArtists"] boolValue];
}

- (void)initializeData {
    [self setupSampleData];
    
    // Save Managed Object Context
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
    
    // Set User Default to prevent another preload of data on startup.
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MR_HasPrefilledArtists"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setupSampleData {
    NSString *url;
    
    // Create Nujabes
    Artist *nujabes = [Artist MR_createEntity];
    nujabes.name = @"Nujabes";
    nujabes.liked = @0;
    nujabes.nowListening = @YES;
    url = @"http://userserve-ak.last.fm/serve/_/44041763/Nujabes+_.jpg";
    [nujabes addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create Modest Mouse
    Artist *modestMouse = [Artist MR_createEntity];
    modestMouse.liked = @0;
    modestMouse.nowListening = @YES;
    modestMouse.name = @"Modest Mouse";
    url = @"http://userserve-ak.last.fm/serve/500/886281/Modest+Mouse.jpg";
    [modestMouse addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create Nightmares on Wax
    Artist *nightmaresOnWax = [Artist MR_createEntity];
    nightmaresOnWax.liked = @0;
    nightmaresOnWax.nowListening = @YES;
    nightmaresOnWax.name = @"Nightmares on Wax";
    url = @"http://userserve-ak.last.fm/serve/_/2162189/Nightmares+on+Wax.jpg";
    [nightmaresOnWax addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create Tokyo Police Club
    Artist *tokyoPoliceClub = [Artist MR_createEntity];
    tokyoPoliceClub.liked = @0;
    tokyoPoliceClub.nowListening = @YES;
    tokyoPoliceClub.name = @"Tokyo Police Club";
    url = @"http://userserve-ak.last.fm/serve/_/4855404/Tokyo+Police+Club+tokyopolice_cover.jpg";
    [tokyoPoliceClub addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create Why?
    Artist *why = [Artist MR_createEntity];
    why.liked = @0;
    why.nowListening = @YES;
    why.name = @"Why?";
    url = @"http://userserve-ak.last.fm/serve/_/28744645/Why+Live+Dublab+Session+PROPER.png";
    [why addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create The Hotelier
    Artist *theHotelier = [Artist MR_createEntity];
    theHotelier.liked = @0;
    theHotelier.nowListening = @YES;
    theHotelier.name = @"The Hotelier";
    url = @"http://userserve-ak.last.fm/serve/500/98412025/The+Hotelier+TheHotelier5.png";
    [theHotelier addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create Grouper
    Artist *grouper = [Artist MR_createEntity];
    grouper.liked = @0;
    grouper.nowListening = @YES;
    grouper.name = @"Grouper";
    url = @"http://userserve-ak.last.fm/serve/500/39859003/Grouper.png";
    [grouper addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create Cass McCombs
    Artist *cassMccombs = [Artist MR_createEntity];
    cassMccombs.liked = @0;
    cassMccombs.nowListening = @YES;
    cassMccombs.name = @"Cass McCombs";
    url = @"http://userserve-ak.last.fm/serve/_/32726321/Cass+McCombs+CASS.jpg";
    [cassMccombs addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create Kanye West
    Artist *yeezus = [Artist MR_createEntity];
    yeezus.liked = @0;
    yeezus.nowListening = @YES;
    yeezus.name = @"Kanye West";
    url = @"http://userserve-ak.last.fm/serve/_/52579947/Kanye+West+kanye+bet+awards.png";
    [yeezus addImagesObject:[Image createEntityWithUrl:url]];
}

@end
