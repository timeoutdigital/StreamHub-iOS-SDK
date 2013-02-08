//
//  LFStreamManager.m
//  LFClient
//
//  Created by zjj on 2/7/13.
//
//  Copyright (c) 2013 Livefyre. All rights reserved.
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

#import "LFStreamManager.h"

static dispatch_queue_t _modify_pollingCollections_queue;
static dispatch_queue_t modify_pollingCollections_queue() {
    if (_modify_pollingCollections_queue == NULL)
        _modify_pollingCollections_queue = dispatch_queue_create("com.livefyre.SDK.pollingCollectionsQueue", NULL);
    
    return _modify_pollingCollections_queue;
}

@interface LFStreamManager()
@property (strong) NSMutableArray *pollingCollections;
@end

@implementation LFStreamManager
@synthesize pollingCollections = _pollingCollections;
//dispatch_sync(modify_pollingCollections_queue(), ^{
//    if (![self.pollingCollections containsObject:collectionId])
//        [self.pollingCollections addObject:collectionId];
//});
//dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//    [self pollForCollection:collectionId fromEvent:eventId withHost:host withPartialPath:eventlessPath success:success failure:failure];;
//});
//__block BOOL isPolling = YES;
//dispatch_sync(modify_pollingCollections_queue(), ^{
//    if (![self.pollingCollections containsObject:collectionId])
//        isPolling = NO;
//});
//if (!isPolling)
//return;
//keep polling
//NSLog(@"Polling for collection:%@", collectionId);
//dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//    [self pollForCollection:collectionId fromEvent:eventId withHost:host withPartialPath:partialPath success:success failure:failure];
//});
//success(payload);
////update the event head
//eventId = [payload valueForKeyPath:@"data.maxEventId"];
- (NSMutableArray *)pollingCollections
{
    if (!_pollingCollections)
        _pollingCollections = [[NSMutableArray alloc] init];
    
    return _pollingCollections;
}

- (void)setPollingCollections:(NSMutableArray *)pollingCollections
{
    self.pollingCollections = pollingCollections;
}

- (void)stopStreamForCollection:(NSString *)collectionId
{
    dispatch_async(modify_pollingCollections_queue(), ^{
        [self.pollingCollections removeObject:collectionId];
    });
}

- (NSArray *)getStreamingCollections
{
    return [NSArray arrayWithArray:self.pollingCollections];
}
@end
