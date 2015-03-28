#import "Image.h"
#import "Artist.h"

@implementation Image

@dynamic size;
@dynamic text;
@dynamic artist;

+(Image *)createEntityWithUrl:(NSString *)url {
    Image *image = [Image MR_createEntity];
    image.text = url;
    return image;
}

@end
