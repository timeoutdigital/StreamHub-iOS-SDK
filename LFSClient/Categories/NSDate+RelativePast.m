//
//  NSDate+RelativePast.h
//  LFSClient
//
//  Created by Eugene Scherba on 8/22/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "NSDate+RelativePast.h"

@implementation NSDate (RelativePast)

- (NSString *)relativePastTime {
    NSTimeInterval time = -[self timeIntervalSinceNow];
    
    if (time < 1) {
        return @"Now";
    } else if (time < 60) {
        return [NSString stringWithFormat:@"%ds", (int)time];
    } else if (time < 3600) {
        return [NSString stringWithFormat:@"%dm", (int)time / 60];
    } else if (time < 86400) {
        return [NSString stringWithFormat:@"%dh", (int)time / 3600];
    } else if (time < 604800) {
        return [NSString stringWithFormat:@"%dd", (int)time / 86400];
    } else if (time < 31536000) {
        return [NSString stringWithFormat:@"%dw", (int)time / 604800];
    } else {
        return [NSString stringWithFormat:@"%dy", (int)time / 31536000];
        //return [NSDateFormatter localizedStringFromDate:self dateStyle:NSDateFormatterShortStyle timeStyle:nil];
    }
}

@end
