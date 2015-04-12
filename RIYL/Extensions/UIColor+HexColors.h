#import <UIKit/UIKit.h>

@interface UIColor (HexColors)

+ (UIColor*)colorWithHexString:(NSString*)hexString;

// General colors
+ (UIColor*)myDarkGrayColor;
+ (UIColor*)myBlueColor;
+ (UIColor*)myRedColor;
+ (UIColor*)myLightGreenColor;
+ (UIColor*)myGreenColor;
+ (UIColor*)myDarkGreenColor;

// Branding colors
+ (UIColor*)mySpotifyGreenColor;
+ (UIColor*)myYoutubeRedColor;

// Transparent colors
+ (UIColor*)myTransparentDarkGrayColor;
+ (UIColor*)myTransparentRedColor;
+ (UIColor*)myTransparentLightGreenColor;

@end
