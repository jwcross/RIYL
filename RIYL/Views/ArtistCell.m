#import "ArtistCell.h"
#import "Artist.h"
#import "UIColor+HexColors.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <libextobjc/EXTScope.h>

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
        // Add subviews
        [self.contentView addSubview:self.backgroundImageView];
        [self.contentView addSubview:self.label];
        [self.contentView addSubview:self.progressView];
        
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
        CGSize textSize = [self.label.text sizeWithAttributes:attrs];
        CGFloat x = 0;
        CGFloat y = bounds.size.height - textSize.height - 2*LABEL_PADDING_Y;
        CGFloat w = textSize.width + 2*LABEL_PADDING_X;
        CGFloat h = textSize.height + 2*LABEL_PADDING_Y;
        CGRectMake(x, y, w, h);
    });
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

@end
