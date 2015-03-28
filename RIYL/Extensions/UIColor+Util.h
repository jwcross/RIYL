#import <UIKit/UIKit.h>

@interface UIColor (Util)

- (BOOL)isLegibleAgainst:(UIColor *)backgroundColor;

- (UIColor *)darken;
- (UIColor *)lighten;

- (CGFloat)brightness;
- (CGFloat)difference:(UIColor *)otherColor;

@end
