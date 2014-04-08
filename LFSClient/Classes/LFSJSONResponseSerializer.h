//
//  LFSJSONResponseSerializer.h
//  LFSClient
//
//  Created by Eugene Scherba on 4/6/14.
//  Copyright (c) 2014 Livefyre. All rights reserved.
//

#import "LFSBaseClient.h"
#import "AFURLResponseSerialization.h"

@interface LFSJSONResponseSerializer : AFJSONResponseSerializer

/**
 @property readingOptions flags that can be passed to JSON decoder
 */
@property (nonatomic, assign) JKFlags readingOptions;

/**
 Creates and returns a JSON serializer with specified reading and writing options.
 
 @param readingOptions The specified JSON reading flags.
 */
+ (instancetype)serializerWithReadingOptions:(JKFlags)readingOptions;

@end
