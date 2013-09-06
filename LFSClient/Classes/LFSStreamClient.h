//
//  LFSStreamClient.h
//  LFSClient
//
//  Created by Eugene Scherba on 9/3/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSBaseClient.h"

@interface LFSStreamClient : LFSBaseClient

@property (nonatomic, strong, readonly) NSURL *collectionStreamURLString;
@property (nonatomic, strong) NSString *collectionId;
@property (nonatomic, strong) NSNumber *eventId;

- (void)setResultHandler:(LFHandleBlock)handler
                 success:(LFSSuccessBlock)success
                 failure:(LFSFailureBlock)failure;

- (void)startStream;

- (void)startStreamWithEventId:(NSNumber*)eventId;

- (void)pauseStream;

- (void)resumeStream;

- (void)stopStream;


@end
