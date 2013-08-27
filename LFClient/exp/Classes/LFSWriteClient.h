//
//  LFSWriteClient.h
//  LFClient
//
//  Created by Eugene Scherba on 8/22/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "lftypes.h"
#import "AFHTTPClient.h"
#import "LFSJSONRequestOperation.h"

@interface LFSWriteClient : AFHTTPClient

@property (nonatomic, readonly, strong) NSString* lfEnvironment;
@property (nonatomic, readonly, strong) NSString* lfNetwork;

/**
 * Initialize Livefyre client
 *
 * @param networkDomain The collection's network as identified by domain, i.e. livefyre.com.
 * @param environment (optional) Where the collection is hosted, i.e. t-402. Used for development/testing purposes.
 * @return LFClient instance
 */

+ (instancetype)clientWithEnvironment:(NSString *)environment
                              network:(NSString *)network;

- (id)initWithEnvironment:(NSString *)environment
                  network:(NSString *)network;


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
