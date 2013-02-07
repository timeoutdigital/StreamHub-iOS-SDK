//
//  LFWriteClient.m
//  LFClient
//
//  Created by zjj on 1/14/13.
//
//  Copyright (c) 2013 Livefyre
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.

#import "LFWriteClient.h"
#import "NSString+QueryString.h"

@implementation LFWriteClient
+ (void)likeContent:(NSString *)contentId
            ForUser:(NSString *)userToken
      ForCollection:(NSString *)collectionId
         ForNetwork:(NSString *)networkDomain
          OnSuccess:(void (^)(NSDictionary *))success
          OnFailure:(void (^)(NSError *))failure
{
    [self likeOrUnlikeContent:contentId ForUser:userToken ForCollection:collectionId ForNetwork:networkDomain Action:@"like" OnSuccess:success OnFailure:failure];
}

+ (void)unlikeContent:(NSString *)contentId
              ForUser:(NSString *)userToken
        ForCollection:(NSString *)collectionId
           ForNetwork:(NSString *)networkDomain
            OnSuccess:(void (^)(NSDictionary *))success
            OnFailure:(void (^)(NSError *))failure
{
    [self likeOrUnlikeContent:contentId ForUser:userToken ForCollection:collectionId ForNetwork:networkDomain Action:@"unlike" OnSuccess:success OnFailure:failure];
}

+ (void)likeOrUnlikeContent:(NSString *)contentId
                    ForUser:(NSString *)userToken
              ForCollection:(NSString *)collectionId
                 ForNetwork:(NSString *)networkDomain
                     Action:(NSString *)actionEndpoint
                  OnSuccess:(void (^)(NSDictionary *))success
                  OnFailure:(void (^)(NSError *))failure
{
    if (!networkDomain || !userToken || !collectionId || !contentId) {
        failure([NSError errorWithDomain:kLFError code:400u userInfo:[NSDictionary dictionaryWithObject:@"Lacking necessary parameters to like content."
                                                                                                 forKey:NSLocalizedDescriptionKey]]);
        return;
    }
    
    NSDictionary *paramsDict = [NSDictionary dictionaryWithObjects:@[collectionId, userToken] forKeys:@[@"collection_id", @"lftoken"]];
    NSString *queryString = [[NSString alloc] initWithParams:paramsDict];
    
    contentId = [contentId stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *host = [NSString stringWithFormat:@"%@.%@", kQuillDomain, networkDomain];
    NSString *path = [NSString stringWithFormat:@"/api/v3.0/message/%@/%@/", contentId, actionEndpoint];

    [self requestWithHost:host
                 WithPath:path
              WithPayload:queryString
               WithMethod:@"POST"
                OnSuccess:success
                OnFailure:failure];
}

+ (void)postContent:(NSString *)body
            ForUser:(NSString *)userToken
          InReplyTo:(NSString *)parentId
      ForCollection:(NSString *)collectionId
         ForNetwork:(NSString *)networkDomain
          OnSuccess:(void (^)(NSDictionary *))success
          OnFailure:(void (^)(NSError *))failure
{
    if (!body || !userToken || !collectionId || !networkDomain) {
        failure([NSError errorWithDomain:kLFError code:400u userInfo:[NSDictionary dictionaryWithObject:@"Lacking necessary parameters to post content."
                                                                                                 forKey:NSLocalizedDescriptionKey]]);
        return;
    }
    
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionaryWithObjects:@[body, userToken] forKeys:@[@"body", @"lftoken"]];
    if (parentId)
        [paramsDict setObject:parentId forKey:@"parent_id"];
    
    NSString *queryString = [[NSString alloc] initWithParams:paramsDict];
    NSString *host = [NSString stringWithFormat:@"%@.%@", kQuillDomain, networkDomain];
    NSString *path = [NSString stringWithFormat:@"/api/v3.0/collection/%@/post/", collectionId];
    
    [self requestWithHost:host
                 WithPath:path
              WithPayload:queryString
               WithMethod:@"POST"
                OnSuccess:success
                OnFailure:failure];
}
@end
