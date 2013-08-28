//
//  LFSAdminClient.m
//  LFClient
//
//  Created by Eugene Scherba on 8/22/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSAdminClient.h"
#import "MF_Base64Additions.h"

@implementation LFSAdminClient

#pragma mark - Overrides
-(NSString*)subdomain { return @"admin"; }

#pragma mark - Methods

- (void)authenticateUserWithToken:(NSString *)userToken // JWT
                       collection:(NSString *)collectionId
                        onSuccess:(LFSuccessBlock)success
                        onFailure:(LFFailureBlock)failure
{
    NSParameterAssert(userToken != nil);
    NSParameterAssert(collectionId != nil);
    
    // Note: changing path still results in tests being passed
    [self getPath:@"/api/v3.0/auth/"
       parameters:@{@"lftoken": userToken,
                    @"collectionId": collectionId}
          success:(AFSuccessBlock)success
          failure:(AFFailureBlock)failure];
}

- (void)authenticateUserWithToken:(NSString *)userToken // JWT
                             site:(NSString *)siteId
                          article:(NSString *)articleId
                        onSuccess:(LFSuccessBlock)success
                        onFailure:(LFFailureBlock)failure
{
    NSParameterAssert(userToken != nil);
    NSParameterAssert(siteId != nil);
    NSParameterAssert(articleId != nil);
    
    // Note: changing path still results in tests being passed
    [self getPath:@"/api/v3.0/auth/"
       parameters:@{@"lftoken": userToken,
                    @"siteId": siteId,
                    @"articleId":[articleId base64String]}
          success:(AFSuccessBlock)success
          failure:(AFFailureBlock)failure];
}

@end
