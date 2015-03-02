#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MGSwipeTableCell/MGSwipeButton.h>
#import <SpinKit/RTSpinKitView.h>
#import <libextobjc/EXTScope.h>
#import "ArtistCell.h"
#import "UIColor+HexColors.h"

@interface ArtistCell ()

@property RTSpinKitView *progressView;
@property UIImageView *backgroundImageView;

@end

@implementation ArtistCell

#define LABEL_FONT [UIFont boldSystemFontOfSize:16.0f]
static const float LABEL_CORNER_RADIUS = 2.0f;
static const float LABEL_PADDING_X = 8.0f;
static const float LABEL_PADDING_Y = 2.0f;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // create background image view
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectNull];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_backgroundImageView];

        // create a label that renders the artist name
        _label = [[UILabel alloc] initWithFrame:CGRectNull];
        _label.textColor = [UIColor whiteColor];
        _label.backgroundColor = [UIColor clearColor];
        _label.font = LABEL_FONT;
        _label.layer.cornerRadius = LABEL_CORNER_RADIUS;
        _label.clipsToBounds = YES;
        _label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_label];
        
        // add SpinKit view
        _progressView = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWave];
        [self.contentView addSubview:_progressView];
        
        // clear background
        self.backgroundColor = [UIColor clearColor];
        
        // clip to bounds for the image view
        self.clipsToBounds = YES;
        self.backgroundView.clipsToBounds = YES;
        
        // remove the default highlight for selected cells
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;   
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = [self.artist.name sizeWithAttributes:@{NSFontAttributeName: LABEL_FONT}];
    _label.frame = CGRectMake(0, self.bounds.size.height - size.height - 2*LABEL_PADDING_Y - 0,
                              size.width + 2*LABEL_PADDING_X, size.height + 2*LABEL_PADDING_Y);
    
    _progressView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _progressView.color = [UIColor whiteColor];
    _backgroundImageView.frame = self.bounds;
}

#pragma mark - setter

-(void)setArtist:(Artist *)artist {
    _artist = artist;
    _label.text = artist.name;
    
    _label.backgroundColor = artist.liked.intValue ==  1 ? [UIColor myTransparentLightGreenColor]
                           : artist.liked.intValue ==  3 ? [UIColor myTransparentRedColor]
                           : [UIColor myTransparentDarkGrayColor];
    // clear cached image
    _backgroundImageView.image = nil;
    
    if (artist.images.count > 0) {
        [self setBackgroundImageForArtist:artist];
    }
}

typedef void (^ImageSuccess)(NSURLRequest*, NSHTTPURLResponse*, UIImage*);
typedef void (^ImageError)(NSURLRequest*, NSHTTPURLResponse*, NSError*);

-(void)setBackgroundImageForArtist:(Artist*)artist {
    [_progressView startAnimating];
    
    NSURL *imageUrl = [NSURL URLWithString:[artist.images[0] text]]; //todo!
    
    @weakify(self)
    ImageSuccess success = ^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        @strongify(self)
        [self.progressView stopAnimating];
        [self.backgroundImageView setImage:image];
    };
    ImageError failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        @strongify(self)
        [self.progressView stopAnimating];
    };
    
    [self.backgroundImageView setImageWithURLRequest:[NSURLRequest requestWithURL:imageUrl]
                                    placeholderImage:nil
                                             success:success
                                             failure:failure];
}

@end
