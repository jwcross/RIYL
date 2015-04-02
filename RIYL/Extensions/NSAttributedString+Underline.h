#import <Foundation/Foundation.h>

@interface NSAttributedString (Underline)

+ (NSAttributedString *)stringWithText:(NSString *)text
                             textColor:(UIColor *)textColor
                        underlineColor:(UIColor *)underlineColor;

@end

@implementation NSAttributedString (Underline)

+ (NSAttributedString *)stringWithText:(NSString *)text
                             textColor:(UIColor *)textColor
                        underlineColor:(UIColor *)underlineColor
{
    NSRange range = NSMakeRange(0, text.length);
    
    // faint underlines
    underlineColor = [underlineColor colorWithAlphaComponent:0.4];
    
    NSMutableAttributedString* string = [[NSMutableAttributedString alloc] initWithString:text];
    [string addAttribute:NSForegroundColorAttributeName value:textColor range:range];
    [string addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
    [string addAttribute:NSUnderlineColorAttributeName value:underlineColor range:range];
    
    return string;
}

@end
