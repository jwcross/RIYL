#import "UIColor+Util.h"

@implementation UIColor (Util)

- (BOOL)isLegibleAgainst:(UIColor *)backgroundColor
{
    CGFloat brightness = ABS([self brightness] - [backgroundColor brightness]);
    CGFloat difference = [self difference:backgroundColor];
    return brightness > 125 && difference > 400;
}

- (CGFloat)brightness
{
    CGFloat R, G, B, A;
    [self getRed:&R green:&G blue:&B alpha:&A];
    
    return 299*R + 587*G + 114*B;
}

- (CGFloat)difference:(UIColor *)otherColor
{
    CGFloat R1, G1, B1, A1;
    CGFloat R2, G2, B2, A2;
    [self getRed:&R1 green:&G1 blue:&B1 alpha:&A1];
    [otherColor getRed:&R2 green:&G2 blue:&B2 alpha:&A2];
    
    return 256*(MAX(R1,R2) + MAX(B1,B2) + MAX(G1,G2)) - 256*(MIN(R1,R2) + MIN(B1,B2) + MIN(G1,G2));
}

- (UIColor *)darken
{
    CGFloat R, G, B, A;
    [self getRed:&R green:&G blue:&B alpha:&A];
    
    CGFloat adjust = 0.10f;
    return [UIColor colorWithRed:R*adjust green:G*adjust blue:B*adjust alpha:1];
}

- (UIColor *)lighten
{
    CGFloat R, G, B, A;
    [self getRed:&R green:&G blue:&B alpha:&A];
    
    CGFloat adjust = 0.90f;
    return [UIColor colorWithRed:(R+adjust*(1-R)) green:(G+adjust*(1-G)) blue:(B+adjust*(1-B)) alpha:1];
}

@end
