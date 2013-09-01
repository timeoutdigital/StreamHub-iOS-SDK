//
//  NSDate+RelativePast.h
//  LFSClient
//
//  Created by Eugene Scherba on 8/22/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (RelativePast)
// Returns fuzzy, human readable, time deltas.
- (NSString *)relativePastTime;
@end
