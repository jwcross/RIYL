//
//  UIColor+HexColors.m
//  SimilarArtists
//
//  Created by Jonathan Crossley on 2/10/15.
//  Copyright (c) 2015 CCS. All rights reserved.
//

#import "UIColor+HexColors.h"

@implementation UIColor (HexColors)

+ (UIColor*)colorWithHexString:(NSString*)hexString {
    return [UIColor colorWithHexString:hexString withAlpha:1.0f];
}

+ (UIColor*)colorWithHexString:(NSString*)hexString withAlpha:(CGFloat)alpha {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0
                           green:((rgbValue & 0xFF00) >> 8)/255.0
                            blue:(rgbValue & 0xFF)/255.0
                           alpha:alpha];
}

+ (UIColor*)myDarkGrayColor {
    return [UIColor colorWithHexString:@"#373c42"];
}

+ (UIColor*)myBlueColor {
    return [UIColor colorWithHexString:@"#0099cc"];
}

+ (UIColor*)myLightGreenColor {
    return [UIColor colorWithHexString:@"#95bf74"];
}

+ (UIColor*)myGreenColor {
    return [UIColor colorWithHexString:@"#68a357"];
}

+ (UIColor*)myDarkGreenColor {
    return [UIColor colorWithHexString:@"#32965d"];
}

+ (UIColor*)myRedColor {
    return [UIColor colorWithHexString:@"#da4167"];
}

static const float ALPHA1 = 0.52f;
static const float ALPHA2 = 0.7f;
static const float ALPHA3 = 0.7f;

+ (UIColor*)myTransparentDarkGrayColor {
    return [UIColor colorWithHexString:@"#373c42" withAlpha:ALPHA1];
}

+ (UIColor*)myTransparentRedColor {
    return [UIColor colorWithHexString:@"#da4167" withAlpha:ALPHA2];
}

+ (UIColor*)myTransparentLightGreenColor {
    return [UIColor colorWithHexString:@"#95bf74" withAlpha:ALPHA3];
}


@end
