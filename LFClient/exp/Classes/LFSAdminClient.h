//
//  LFSAdminClient.h
//  LFClient
//
//  Created by Eugene Scherba on 8/22/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "lftypes.h"
#import "AFHTTPClient.h"
#import "LFSJSONRequestOperation.h"

@interface LFSAdminClient : AFHTTPClient

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


/** @name User Authentication */

/**
 * Check a user's token against the auth admin.
 *
 * It is necessary to provide either a collectionId or a siteId combined with an articleId.
 *
 * @param userToken The lftoken representing a user.
 * @param collectionId The Id of the collection to auth against.
 * @param success Callback called with a dictionary after the user data has
 * been retrieved.
 * @param failure Callback called with an error after a failure to retrieve data.
 * @return void
 */

- (void)authenticateUserWithToken:(NSString *)userToken
                       collection:(NSString *)collectionId
                        onSuccess:(LFSuccessBlock)success
                        onFailure:(LFFailureBlock)failure;


/**
 * Check a user's token against the auth admin.
 *
 * It is necessary to provide either a collectionId or a siteId combined with an articleId.
 *
 * @param userToken The lftoken representing a user.
 * @param siteId The Id of the article's site.
 * @param articleId The Id of the collection's article.
 * @param success Callback called with a dictionary after the user data has
 * been retrieved.
 * @param failure Callback called with an error after a failure to retrieve data.
 * @return void
 */

- (void)authenticateUserWithToken:(NSString *)userToken
                             site:(NSString *)siteId
                          article:(NSString *)articleId
                        onSuccess:(LFSuccessBlock)success
                        onFailure:(LFFailureBlock)failure;

@end
