#import <Foundation/Foundation.h>
#import "NSString+LastFm.h"

@implementation NSString (LastFm)

- (NSString*)formatBioWithArtist:(NSString *)artistName
{
    NSString *s = self;
    s = [s replaceHtmlCodes];
    s = [s stripHtml];
    s = [s stripCreativeCommons];
    s = [s stripLastFmLinks:artistName];
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
                             @"&micro;" : @"µ",
                             @"&nbsp;"  : @"\u00a0",
                             @"&aacute;"  : @"\u00e1",
                             @"&eacute;"  : @"\u00e9",
                             @"&iacute;"  : @"\u00ed",
                             @"&oacute;"  : @"\u00f3",
                             @"&uacute;"  : @"\u00fa",
                             @"&Aacute;"  : @"\u00c1",
                             @"&Eacute;"  : @"\u00c9",
                             @"&Iacute;"  : @"\u00cd",
                             @"&Oacute;"  : @"\u00d3",
                             @"&Uacute;"  : @"\u00da",
                             @"&rsquo;"  : @"\u2019",
                             @"&nbsp;"  : @"\u00a0",
                             @"&Ccedil;" : @"\u00c7",
                             @"&ccedil;" : @"\u00e7",
                             };
    
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
    
    // strip whitespace and newlines
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    s = [s stringByTrimmingCharactersInSet:charSet];
    
    return s;
}


@end
