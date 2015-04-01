#import <Foundation/Foundation.h>
#import "NSString+LastFm.h"

@implementation NSString (LastFm)

- (NSString*)formatBioWithArtist:(NSString *)artistName
{
    NSString *s = self;
    s = [s stripHtml];
    s = [s stripCreativeCommons];
    s = [s stripLastFmLinks:artistName];
    s = [s replaceHtmlCodes];
    s = [s stripWhitespace];
    
    return s;
}

- (NSString *)stripHtml
{
    NSString *s = [self copy];
    NSRange r;
    
    while ((r = [s findHtmlTags]).location != NSNotFound) {
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    }
    return s;
}

- (NSRange)findHtmlTags
{
    return [self rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch];
}

- (NSString *)replaceHtmlCodes
{
    NSString *s = [self copy];
    NSDictionary *codes = @{ @"&quot;"  : @"\"",
                             @"&amp;"   : @"&",
                             @"&lt;"    : @"<",
                             @"&gt;"    : @">",
                             @"&nbsp;"  : @"\u00a0",
                             @"&micro;" : @"µ", };
    
    for (NSString *code in codes.keyEnumerator) {
        s = [s stringByReplacingOccurrencesOfString:code
                                         withString:codes[code]];
    }
    return s;
}

- (NSString *)stripCreativeCommons
{
    NSString *creativeCommons = @"User-contributed text is available under the "
        "Creative Commons By-SA License and may also be available under the GNU FDL.";
    return [self stringByReplacingOccurrencesOfString:creativeCommons withString:@""];
}

- (NSString *)stripLastFmLinks:(NSString *)artistName
{
    NSString *s = [self copy];
    
    // remove "read more on last.fm"
    NSString *readMore = [NSString stringWithFormat:@"Read more about %@ on Last.fm.", artistName];
    s = [s stringByReplacingOccurrencesOfString:readMore withString:@""];
    
    // remove "artist on last.fm"
    readMore = [NSString stringWithFormat:@"%@ on Last.fm.", artistName];
    s = [s stringByReplacingOccurrencesOfString:readMore withString:@""];
    
    return s;
}

- (NSString *)stripWhitespace
{
    NSString *s = [self copy];
    
    // strip newlines
    NSCharacterSet *charSet = [NSCharacterSet newlineCharacterSet];
    s = [s stringByTrimmingCharactersInSet:charSet];
    
    // strip whitespace
    charSet = [NSCharacterSet whitespaceCharacterSet];
    return [s stringByTrimmingCharactersInSet:charSet];
}


@end
