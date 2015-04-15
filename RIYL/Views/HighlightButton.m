//
//  Created by Jonathan Crossley on 4/15/15.
//  Copyright (c) 2015 CCS. All rights reserved.
//

#import "HighlightButton.h"

@implementation HighlightButton

- (void)setHighlighted:(BOOL)highlighted
{
    if (highlighted) {
        self.backgroundColor = self.highlightColor;
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

@end
