#import "InitialDataHelper.h"
#import "Image.h"
#import "Artist.h"

@implementation InitialDataHelper

+ (InitialDataHelper *)sharedInstance
{
    static InitialDataHelper *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] init];
    });
    return _sharedClient;
}

- (BOOL)hasPrefilledArtists
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"MR_HasPrefilledArtists"] boolValue];
}

- (void)initializeData
{
    [self setupSampleData];
    
    // Save Managed Object Context
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
    
    // Set User Default to prevent another preload of data on startup.
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MR_HasPrefilledArtists"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setupSampleData
{
    NSString *url;
    
    // Create Animal Collective
    Artist *animalCollective = [Artist MR_createEntity];
    animalCollective.name = @"Animal Collective";
    animalCollective.liked = @0;
    animalCollective.nowListening = @YES;
    url = @"http://userserve-ak.last.fm/serve/500/72740852/Animal+Collective.png";
    [animalCollective addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create Azaelia Banks
    Artist *azaeliaBanks = [Artist MR_createEntity];
    azaeliaBanks.name = @"Azaelia Banks";
    azaeliaBanks.liked = @0;
    azaeliaBanks.nowListening = @YES;
    url = @"http://userserve-ak.last.fm/serve/_/103918225/Azealia+Banks++for+Playboy.png";
    [azaeliaBanks addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create Cass McCombs
    Artist *cassMcCombs = [Artist MR_createEntity];
    cassMcCombs.name = @"Cass McCombs";
    cassMcCombs.liked = @0;
    cassMcCombs.nowListening = @YES;
    url = @"http://userserve-ak.last.fm/serve/_/32726321/Cass+McCombs+CASS.jpg";
    [cassMcCombs addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create Childish Gambino
    Artist *childishGambino = [Artist MR_createEntity];
    childishGambino.name = @"Childish Gambino";
    childishGambino.liked = @0;
    childishGambino.nowListening = @YES;
    url = @"http://userserve-ak.last.fm/serve/_/99444305/Childish+Gambino+5687920933682.png";
    [childishGambino addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create Django Reinhardt
    Artist *djangoReinhardt = [Artist MR_createEntity];
    djangoReinhardt.name = @"Django Reinhardt";
    djangoReinhardt.liked = @0;
    djangoReinhardt.nowListening = @YES;
    url = @"http://userserve-ak.last.fm/serve/_/2145863/Django+Reinhardt.jpg";
    [djangoReinhardt addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create Flaming Lips
    Artist *flamingLips = [Artist MR_createEntity];
    flamingLips.name = @"The Flaming Lips";
    flamingLips.liked = @0;
    flamingLips.nowListening = @YES;
    url = @"http://userserve-ak.last.fm/serve/500/5923439/The+Flaming+Lips+frenzy.jpg";
    [flamingLips addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create Grouper
    Artist *grouper = [Artist MR_createEntity];
    grouper.name = @"Grouper";
    grouper.liked = @0;
    grouper.nowListening = @YES;
    url = @"http://userserve-ak.last.fm/serve/500/39859003/Grouper.png";
    [grouper addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create Kanye West
    Artist *kanyeWest = [Artist MR_createEntity];
    kanyeWest.name = @"Kanye West";
    kanyeWest.liked = @0;
    kanyeWest.nowListening = @YES;
    url = @"http://userserve-ak.last.fm/serve/_/52579947/Kanye+West+kanye+bet+awards.png";
    [kanyeWest addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create Kendrick Lamar
    Artist *kendrickLamar = [Artist MR_createEntity];
    kendrickLamar.name = @"Kendrick Lamar";
    kendrickLamar.liked = @0;
    kendrickLamar.nowListening = @YES;
    url = @"http://userserve-ak.last.fm/serve/_/101348633/Kendrick+Lamar.png";
    [kendrickLamar addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create Purity Ring
    Artist *purityRing = [Artist MR_createEntity];
    purityRing.name = @"Purity Ring";
    purityRing.liked = @0;
    purityRing.nowListening = @YES;
    url = @"http://userserve-ak.last.fm/serve/500/80458637/Purity+Ring++900x800+PNG.png";
    [purityRing addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create Skrillex
    Artist *skrillex = [Artist MR_createEntity];
    skrillex.name = @"Skrillex";
    skrillex.liked = @0;
    skrillex.nowListening = @YES;
    url = @"http://userserve-ak.last.fm/serve/_/66655236/Skrillex+png.png";
    [skrillex addImagesObject:[Image createEntityWithUrl:url]];
    
    // Create Taylor Swift
    Artist *taylorSwift = [Artist MR_createEntity];
    taylorSwift.name = @"Taylor Swift";
    taylorSwift.liked = @0;
    taylorSwift.nowListening = @YES;
    url = @"http://userserve-ak.last.fm/serve/_/103340917/Taylor+Swift+Keds.png";
    [taylorSwift addImagesObject:[Image createEntityWithUrl:url]];
}

@end
