//
//  NSDate+RelativePast.m
//  LivefyreClient
//
//  Created by Thomas Goyne on 8/29/12.
//
//  Copyright (c) 2013 Livefyre
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.

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
