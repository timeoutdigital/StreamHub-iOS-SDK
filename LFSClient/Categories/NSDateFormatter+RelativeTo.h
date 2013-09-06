//
//  NSDateFormatter+RelativeTo.h
//  LFSClient
//
//  Created by Eugene Scherba on 9/6/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (RelativeTo)

- (NSString*)relativeStringFromDate:(NSDate*)date;
- (NSString*)relativeStringFromDate:(NSDate *)date relativeTo:(NSDate*)anotherDate;

@end
