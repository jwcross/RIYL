#import "ArtistCell.h"
#import "Artist.h"
#import "UIColor+HexColors.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <SpinKit/RTSpinKitView.h>
#import <libextobjc/EXTScope.h>

@interface ArtistCell ()

@property (nonatomic) RTSpinKitView *progressView;
@property (nonatomic) UIImageView *backgroundImageView;
@property (nonatomic) UILabel *label;

@end

@implementation ArtistCell

static const float LABEL_FONT_SIZE = 16.0f;
static const float LABEL_CORNER_RADIUS = 2.0f;
static const float LABEL_PADDING_X = 8.0f;
static const float LABEL_PADDING_Y = 2.0f;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *subviews = @[self.backgroundImageView, self.label, self.progressView];
        for (UIView *subview in subviews) {
            [self.contentView addSubview:subview];
        }
        
        // Clear background
        self.backgroundColor = [UIColor clearColor];
        
        // Remove the default highlight for selected cells
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // Remove default separator insets
        self.separatorInset = UIEdgeInsetsZero;
        self.layoutMargins = UIEdgeInsetsZero;
        self.preservesSuperviewLayoutMargins = NO;
    }
    return self;   
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    
    self.backgroundImageView.frame = bounds;
    self.progressView.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    self.label.frame = ({
        NSDictionary *attrs = @{ NSFontAttributeName : self.label.font };
        CGSize textSize = [self.artist.name sizeWithAttributes:attrs];
        CGFloat y = bounds.size.height - textSize.height - 2*LABEL_PADDING_Y;
        CGFloat w = textSize.width + 2*LABEL_PADDING_X;
        CGFloat h = textSize.height + 2*LABEL_PADDING_Y;
        CGRectMake(0, y, w, h);
    });
}

#pragma mark - Public

- (void)setArtist:(Artist *)artist
{
    _artist = artist;
    
    self.label.text = artist.name;
    self.label.backgroundColor = [self labelColorForArtist:artist];
    
    [self fetchBackgroundImageForArtist:artist];
}

#pragma mark - Subviews

- (UIImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] init];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImageView.clipsToBounds = YES;
    }
    return _backgroundImageView;
}

- (UILabel *)label
{
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textColor = [UIColor whiteColor];
        _label.backgroundColor = [UIColor clearColor];
        _label.layer.cornerRadius = LABEL_CORNER_RADIUS;
        _label.textAlignment = NSTextAlignmentCenter;
        _label.userInteractionEnabled = NO;
        _label.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
        _label.clipsToBounds = YES;
    }
    return _label;
}

- (RTSpinKitView *)progressView
{
    if (!_progressView) {
        _progressView = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWave];
        _progressView.color = [UIColor whiteColor];
    }
    return _progressView;
}

#pragma mark - Private

- (UIColor *)labelColorForArtist:(Artist *)artist
{
    switch (artist.liked.intValue) {
        case 1:  return [UIColor myTransparentLightGreenColor];  // liked
        case 3:  return [UIColor myTransparentRedColor];         // disliked
        default: return [UIColor myTransparentDarkGrayColor];    // no opinion
    }
}

typedef void (^ImageSuccess)(NSURLRequest*, NSHTTPURLResponse*, UIImage*);
typedef void (^ImageError)(NSURLRequest*, NSHTTPURLResponse*, NSError*);

- (void)fetchBackgroundImageForArtist:(Artist*)artist
{
    // Clear background image
    self.backgroundImageView.image = nil;
    
    // Return early if artist has no images
    if (artist.images.count == 0) {
        return;
    }
    
    // Define callbacks
    @weakify(self)
    ImageSuccess success = ^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        @strongify(self)
        [self.progressView stopAnimating];
        self.backgroundImageView.image = image;
    };
    ImageError failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        @strongify(self)
        [self.progressView stopAnimating];
    };
    
    // Fetch artist image and clear spinner on success
    [self.progressView startAnimating];
    NSURL *imageUrl = [NSURL URLWithString:[artist.images.firstObject text]];
    [self.backgroundImageView setImageWithURLRequest:[NSURLRequest requestWithURL:imageUrl]
                                    placeholderImage:nil
                                             success:success
                                             failure:failure];
}

@end
