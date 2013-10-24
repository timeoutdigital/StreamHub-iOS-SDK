//
//  LFSWriteClient.m
//  LFSClient
//
//  Created by Eugene Scherba on 8/22/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSWriteClient.h"
#import <JWT/JWT.h>
#import <NSString-Hashes/NSString+Hashes.h>


@implementation LFSWriteClient

#pragma mark - Overrides
-(NSString*)subdomain { return @"quill"; }

#pragma mark - Methods

-(void)postMessage:(LFSMessageAction)action
        forContent:(NSString *)contentId
      inCollection:(NSString *)collectionId
         userToken:(NSString *)userToken
        parameters:(NSDictionary *)parameters
         onSuccess:(LFSSuccessBlock)success
         onFailure:(LFSFailureBlock)failure
{
    NSParameterAssert(contentId != nil);
    NSParameterAssert(collectionId != nil);
    NSParameterAssert(userToken != nil);
    NSParameterAssert((NSUInteger)action < LFS_OPINE_ENDPOINTS_LENGTH);
    
    const NSString *actionEndpoint = LFSMessageEndpoints[action];
    
    NSMutableDictionary *parameters1 =
    [NSMutableDictionary
     dictionaryWithObjects:@[contentId, collectionId, userToken]
     forKeys:@[@"message_id", @"collection_id", @"lftoken"]];
    
    // parameters passed in can be @{ notes: @"...", email: @"..." }
    [parameters1 addEntriesFromDictionary:parameters];
    
    NSString *path = [NSString
                      stringWithFormat:@"/api/v3.0/message/%@/%@/",
                      contentId, actionEndpoint];
    
    [self postPath:path
        parameters:parameters1
           success:success
           failure:failure];
}

- (void)postFlag:(LFSContentFlag)flag
      forContent:(NSString *)contentId
    inCollection:(NSString *)collectionId
       userToken:(NSString*)userToken
      parameters:(NSDictionary*)parameters
       onSuccess:(LFSSuccessBlock)success
       onFailure:(LFSFailureBlock)failure
{
    NSParameterAssert(contentId != nil);
    NSParameterAssert(collectionId != nil);
    NSParameterAssert(userToken != nil);
    NSParameterAssert((NSUInteger)flag < LFS_CONTENT_FLAGS_LENGTH);
    
    NSMutableDictionary *parameters1 =
    [NSMutableDictionary
     dictionaryWithObjects:@[contentId, collectionId, userToken]
     forKeys:@[@"message_id", @"collection_id", @"lftoken"]];
    
    // parameters passed in can be @{ notes: @"...", email: @"..." }
    [parameters1 addEntriesFromDictionary:parameters];
    
    NSString *path = [NSString
                      stringWithFormat:@"/api/v3.0/message/%@/flag/%@/",
                      contentId, LFSContentFlags[flag]];
    
    [self postPath:path
        parameters:parameters1
           success:success
           failure:failure];
}

- (void)postContent:(NSString *)body
       inCollection:(NSString *)collectionId
          userToken:(NSString*)userToken
          inReplyTo:(NSString *)parentId
          onSuccess:(LFSSuccessBlock)success
          onFailure:(LFSFailureBlock)failure
{
    NSParameterAssert(body != nil);
    NSParameterAssert(userToken != nil);
    NSParameterAssert(collectionId != nil);
    
    // TODO: figure out whether to use defaults like this throughout
    if (userToken == nil) {
        userToken = @"";
    }
    
    NSMutableDictionary *parameters =
    [NSMutableDictionary
     dictionaryWithObjects:@[body, userToken]
     forKeys:@[@"body", @"lftoken"]];
    
    if (parentId) {
        [parameters setObject:parentId forKey:@"parent_id"];
    }
    
    NSString *path = [NSString
                      stringWithFormat:@"/api/v3.0/collection/%@/post/",
                      collectionId];
    
    [self postPath:path
        parameters:parameters
           success:success
           failure:failure];
}

-(void)postArticleForSite:(NSString*)siteId
              withSiteKey:(NSString*)siteKey
           collectionMeta:(NSDictionary*)collectionMeta
                onSuccess:(LFSSuccessBlock)success
                onFailure:(LFSFailureBlock)failure
{
    // https://github.com/Livefyre/lfdj/blob/production/lfwrite/lfwrite/api/v3_0/site/collection.py#L26
    // https://github.com/Livefyre/lfdj/blob/production/lfcore/lfcore/v2/network/steps.py#L476
    //
    static NSString *const LFSCollectionMetaParameterKey = @"collectionMeta";
    static NSString *const LFSCollectionChecksumParameterKey = @"checksum";
    
    NSString *articleId = [collectionMeta objectForKey:LFSCollectionMetaArticleIdKey];
    NSString *urlString = [collectionMeta objectForKey:LFSCollectionMetaURLKey];
    NSString *title = [collectionMeta objectForKey:LFSCollectionMetaTitleKey];

    NSParameterAssert(articleId != nil && [articleId length] <= 255);
    NSParameterAssert(urlString != nil);
    NSParameterAssert(siteId != nil);
    NSParameterAssert(siteKey == nil || (title != nil && [title length] <= 255));

    NSMutableDictionary *mutableMeta = [collectionMeta mutableCopy];
    
    // tags are optional and have to be stringified
    NSArray *tagArray = [collectionMeta objectForKey:LFSCollectionMetaTagsKey];
    if (tagArray != nil) {
        [mutableMeta setObject:[tagArray componentsJoinedByString:@","]
                        forKey:LFSCollectionMetaTagsKey];
    }
    
    NSDictionary *parameters;
    if (siteKey != nil) {
        // signed request
        NSString *collectionMetaString = [JWT encodePayload:mutableMeta withSecret:siteKey];
        parameters = @{LFSCollectionMetaParameterKey     : collectionMetaString,
                       LFSCollectionChecksumParameterKey : [collectionMetaString md5]};
    } else {
        // unsigned request
        parameters = @{LFSCollectionMetaParameterKey     : mutableMeta};
    }
    
    NSURL *fullURL = [self.baseURL
                      URLByAppendingPathComponent:
                      [NSString stringWithFormat:@"/api/v3.0/site/%@/collection/create",
                       siteId]];
    
    [self postURL:fullURL
       parameters:parameters
parameterEncoding:AFJSONParameterEncoding
          success:success
          failure:failure];
}

@end
