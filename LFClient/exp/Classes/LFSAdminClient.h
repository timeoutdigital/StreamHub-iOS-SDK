//
//  LFSAdminClient.h
//  LFClient
//
//  Created by Eugene Scherba on 8/22/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSBaseClient.h"

@interface LFSAdminClient : LFSBaseClient

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
