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
 Options for reading the response JSON data and creating the corresponding objects
 */
@property (nonatomic, assign) JKFlags readingOptions;

/**
 Creates and returns a JSON serializer with specified reading and writing options.
 
 @param readingOptions The specified JSON reading options.
 */
+ (instancetype)serializerWithReadingOptions:(JKFlags)readingOptions;

@end
