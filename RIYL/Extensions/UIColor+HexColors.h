//
//  UIColor+HexColors.h
//  SimilarArtists
//
//  Created by Jonathan Crossley on 2/10/15.
//  Copyright (c) 2015 CCS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexColors)

+ (UIColor*)colorWithHexString:(NSString*)hexString;

+ (UIColor*)myDarkGrayColor;
+ (UIColor*)myBlueColor;
+ (UIColor*)myRedColor;
+ (UIColor*)myLightGreenColor;
+ (UIColor*)myGreenColor;
+ (UIColor*)myDarkGreenColor;

+ (UIColor*)myTransparentDarkGrayColor;
+ (UIColor*)myTransparentRedColor;
+ (UIColor*)myTransparentLightGreenColor;

@end
