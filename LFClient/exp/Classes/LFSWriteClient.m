//
//  LFSWriteClient.m
//  LFClient
//
//  Created by Eugene Scherba on 8/22/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSWriteClient.h"
#import "JWT.h"
#import "NSString+Hashes.h"

static const NSString* const LFSOpinionString[] = {
    @"like",
    @"unlike"
};

static const NSString* const LFSUserFlagString[] = {
    @"offensive",
    @"spam",
    @"disagree",
    @"off-topic"
};

@implementation LFSWriteClient

#pragma mark - Overrides
-(NSString*)subdomain {
    return @"quill";
}

#pragma mark - Methods

- (void)postOpinion:(LFSOpinion)action
            forUser:(NSString*)userToken
         forContent:(NSString *)contentId
       inCollection:(NSString *)collectionId
          onSuccess:(LFSuccessBlock)success
          onFailure:(LFFailureBlock)failure
{
    NSParameterAssert(contentId != nil);
    
    const NSString *actionEndpoint = LFSOpinionString[action];
    NSDictionary *parameters = @{@"collection_id":collectionId,
                                 @"lftoken": userToken};
    NSString *path = [NSString
                      stringWithFormat:@"/api/v3.0/message/%@/%@/",
                      contentId, actionEndpoint];
    
    [self postPath:path
        parameters:parameters
           success:success
           failure:failure];
}

- (void)postFlag:(LFSUserFlag)flag
         forUser:(NSString*)userToken
      forContent:(NSString *)contentId
    inCollection:(NSString *)collectionId
      parameters:(NSDictionary*)parameters
       onSuccess:(LFSuccessBlock)success
       onFailure:(LFFailureBlock)failure
{
    NSParameterAssert(contentId != nil);
    
    const NSString *flagString = LFSUserFlagString[flag];
    NSMutableDictionary *parameters1 =
    [NSMutableDictionary
     dictionaryWithObjects:@[contentId, collectionId, flagString, userToken]
     forKeys:@[@"message_id", @"collection_id", @"flag", @"lftoken"]];
    
    // parameters passed in can be { notes: @"...", email: @"..." }
    [parameters1 addEntriesFromDictionary:parameters];
    NSString *path = [NSString
                      stringWithFormat:@"/api/v3.0/message/%@/flag/%@/",
                      contentId, flagString];
    
    [self postPath:path
        parameters:parameters1
           success:success
           failure:failure];
    
}

- (void)postContent:(NSString *)body
            forUser:(NSString*)userToken
      forCollection:(NSString *)collectionId
          inReplyTo:(NSString *)parentId
          onSuccess:(LFSuccessBlock)success
          onFailure:(LFFailureBlock)failure
{
    NSParameterAssert(body != nil);
    NSParameterAssert(collectionId != nil);
    
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

// Creates "signed" collection
- (void)createCollection:(NSString*)articleId
                 forSite:(NSString*)siteId
           secretSiteKey:(NSString*)secretSiteKey
                   title:(NSString*)title
                    tags:(NSArray*)tagArray
                 withURL:(NSURL *)newURL
               onSuccess:(LFSuccessBlock)success
               onFailure:(LFFailureBlock)failure
{
    NSParameterAssert(articleId != nil);
    NSParameterAssert(newURL != nil); //TODO: issue ticket to remove this requirement
    NSParameterAssert(siteId != nil);
    NSParameterAssert([title length] <= 255);
    NSParameterAssert([articleId length] <= 255);
    
    // JSON-encode and concatenate tag array
    NSDictionary *dict = @{@"title":title,
                          @"url":[newURL absoluteString],
                          @"tags":[tagArray componentsJoinedByString:@","],
                          @"articleId":articleId};
    
    NSString *collectionMeta = [JWT encodePayload:dict
                                       withSecret:secretSiteKey];
    
    NSDictionary *parameters = @{@"collectionMeta": collectionMeta,
                                 @"checksum": [collectionMeta md5]};
    
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

- (void)createCollection:(NSString*)articleId
                 forSite:(NSString*)siteId
                   title:(NSString*)title
                    tags:(NSArray*)tagArray
                 withURL:(NSURL *)newURL
               onSuccess:(LFSuccessBlock)success
               onFailure:(LFFailureBlock)failure
{
    NSParameterAssert(articleId != nil);
    NSParameterAssert(newURL != nil); //TODO: issue ticket to remove this requirement
    NSParameterAssert(siteId != nil);
    NSParameterAssert([title length] <= 255);
    NSParameterAssert([articleId length] <= 255);
    
    // JSON-encode and concatenate tag array
    NSDictionary *dict = @{@"title":title,
                           @"url":[newURL absoluteString],
                           @"tags":[tagArray componentsJoinedByString:@","],
                           @"articleId":articleId,
                           @"signed":[NSNumber numberWithBool:NO]};
    
    NSDictionary *parameters = @{@"collectionMeta":dict};
    
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
