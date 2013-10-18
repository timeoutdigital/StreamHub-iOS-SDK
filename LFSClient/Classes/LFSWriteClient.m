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

// (for internal use):
// https://github.com/Livefyre/lfdj/blob/production/lfwrite/lfwrite/api/v3_0/urls.py#L75
#define LFS_OPINE_ENDPOINTS_LENGTH 15u
static const NSString* const LFSMessageEndpoints[LFS_OPINE_ENDPOINTS_LENGTH] =
{
    @"edit",            // 0
    @"approve",         // 1
    @"unapprove",       // 2
    @"hide",            // 3
    @"unhide",          // 4
    @"delete",          // 5
    @"bozo",            // 6
    @"ignore-flags",    // 7
    @"add-note",        // 8
    
    @"like",            // 9
    @"unlike",          // 10
    @"flag",            // 11
    @"mention",         // 12
    @"share",           // 13
    @"vote"             // 14
};

// (for internal use):
// https://github.com/Livefyre/lfdj/blob/production/lfwrite/lfwrite/api/v3_0/urls.py#L87
#define LFS_CONTENT_FLAGS_LENGTH 4u
static const NSString* const LFSContentFlags[LFS_CONTENT_FLAGS_LENGTH] =
{
    @"spam",            // 0
    @"offensive",       // 1
    @"disagree",        // 2
    @"off-topic"        // 3
};

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

- (void)postArticle:(NSString*)articleId
            forSite:(NSString*)siteId
      secretSiteKey:(NSString*)secretSiteKey
              title:(NSString*)title
               tags:(NSArray*)tagArray
            withURL:(NSURL *)newURL
          onSuccess:(LFSSuccessBlock)success
          onFailure:(LFSFailureBlock)failure
{
    NSParameterAssert(articleId != nil);
    NSParameterAssert(newURL != nil);
    NSParameterAssert(siteId != nil);
    NSParameterAssert(title != nil);
    NSParameterAssert([title length] <= 255);
    NSParameterAssert([articleId length] <= 255);
    
    NSDictionary *dict = @{@"title":title,
                           @"url":[newURL absoluteString],
                           @"tags":[tagArray componentsJoinedByString:@","],
                           @"articleId":articleId,
                           @"signed":[NSNumber numberWithBool:(secretSiteKey != nil)]};
    
    NSDictionary *parameters;
    if (secretSiteKey != nil) {
        NSString *collectionMeta = [JWT encodePayload:dict
                                           withSecret:secretSiteKey];
        parameters = @{@"collectionMeta":collectionMeta,
                       @"checksum":[collectionMeta md5]};
    } else {
        parameters = @{@"collectionMeta":dict};
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
