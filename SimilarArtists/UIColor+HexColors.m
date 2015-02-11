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
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0
                           green:((rgbValue & 0xFF00) >> 8)/255.0
                            blue:(rgbValue & 0xFF)/255.0
                           alpha:1.0];
}

+ (UIColor*)myDarkGrayColor {
    return [UIColor colorWithHexString:@"#373c42"];
}

+ (UIColor*)myBlueColor {
    return [UIColor colorWithHexString:@"#0099cc"];
}

@end
