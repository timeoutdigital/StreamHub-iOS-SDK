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
@property (nonatomic, readonly, strong) NSString* lfUser;

/**
 * Initialize Livefyre client
 *
 * @param networkDomain The collection's network as identified by domain, i.e. livefyre.com.
 * @param environment (optional) Where the collection is hosted, i.e. t-402. Used for development/testing purposes.
 * @return LFClient instance
 */

+ (instancetype)clientWithEnvironment:(NSString *)environment
                              network:(NSString *)network
                                 user:(NSString *)userToken;

- (id)initWithEnvironment:(NSString *)environment
                  network:(NSString *)network
                     user:(NSString *)userToken;


- (void)postOpinion:(LFSOpinion)action
         forContent:(NSString *)contentId
       inCollection:(NSString *)collectionId
          onSuccess:(LFSuccessBlock)success
          onFailure:(LFFailureBlock)failure;

- (void)postFlag:(LFSUserFlag)flag
      forContent:(NSString *)contentId
    inCollection:(NSString *)collectionId
      parameters:(NSDictionary*)parameters
       onSuccess:(LFSuccessBlock)success
       onFailure:(LFFailureBlock)failure;

- (void)postContent:(NSString *)body
      forCollection:(NSString *)collectionId
          inReplyTo:(NSString *)parentId
          onSuccess:(LFSuccessBlock)success
          onFailure:(LFFailureBlock)failure;
@end
