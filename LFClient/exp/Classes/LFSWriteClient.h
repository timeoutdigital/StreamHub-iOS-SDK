//
//  LFSWriteClient.h
//  LFClient
//
//  Created by Eugene Scherba on 8/22/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSBaseClient.h"

@interface LFSWriteClient : LFSBaseClient

- (void)postOpinion:(LFSOpinion)action
            forUser:(NSString *)userToken
         forContent:(NSString *)contentId
       inCollection:(NSString *)collectionId
          onSuccess:(LFSuccessBlock)success
          onFailure:(LFFailureBlock)failure;

- (void)postFlag:(LFSUserFlag)flag
         forUser:(NSString *)userToken
      forContent:(NSString *)contentId
    inCollection:(NSString *)collectionId
      parameters:(NSDictionary *)parameters
       onSuccess:(LFSuccessBlock)success
       onFailure:(LFFailureBlock)failure;

- (void)postContent:(NSString *)body
            forUser:(NSString *)userToken
      forCollection:(NSString *)collectionId
          inReplyTo:(NSString *)parentId
          onSuccess:(LFSuccessBlock)success
          onFailure:(LFFailureBlock)failure;

- (void)createCollection:(NSString *)articleId
                 forSite:(NSString *)siteId
           secretSiteKey:(NSString *)secretSiteKey
                   title:(NSString *)title
                    tags:(NSArray *)tagArray
                 withURL:(NSURL *)newURL
               onSuccess:(LFSuccessBlock)success
               onFailure:(LFFailureBlock)failure;

- (void)createCollection:(NSString *)articleId
                 forSite:(NSString *)siteId
                   title:(NSString *)title
                    tags:(NSArray *)tagArray
                 withURL:(NSURL *)newURL
               onSuccess:(LFSuccessBlock)success
               onFailure:(LFFailureBlock)failure;
@end
