//
//  LFPublicAPIClient.m
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

#import "LFPublicAPIClient.h"
#import "NSString+QueryString.h"

@implementation LFPublicAPIClient
+ (void)getTrendingCollectionsForTag:(NSString *)tag
                             ForSite:(NSString *)siteId
                          ForNetwork:(NSString *)networkDomain
                      DesiredResults:(NSUInteger)number
                           OnSuccess:(void (^)(NSArray *))success
                           OnFailure:(void (^)(NSError *))failure
{
    if (!networkDomain) {
        failure([NSError errorWithDomain:kLFError code:400u userInfo:[NSDictionary dictionaryWithObject:@"Lacking necessary parameters to get trending collections."
                                                                                                 forKey:NSLocalizedDescriptionKey]]);
        return;
    }
    
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    if (tag)
        [paramsDict setObject:tag forKey:@"tag"];
    if (siteId)
        [paramsDict setObject:siteId forKey:@"site"];
    if (number)
        [paramsDict setObject:[NSString stringWithFormat:@"%d", number] forKey:@"number"];
    NSString *queryString = [[NSString alloc] initWithParams:paramsDict];
    
    NSString *host = [NSString stringWithFormat:@"%@.%@", kBootstrapDomain, networkDomain];
    NSString *path = [NSString stringWithFormat:@"/api/v3.0/hottest/%@", queryString];
    
    [self requestWithHost:host
                 WithPath:path
              WithPayload:nil
               WithMethod:@"GET"
                OnSuccess:^(NSDictionary *res) {
                  NSArray *results = [res objectForKey:@"data"];
                  if (results)
                      success(results);
              }
                OnFailure:failure];
}
 
+ (void)getUserContentForUser:(NSString *)userId
                    WithToken:(NSString *)userToken
                   ForNetwork:(NSString *)networkDomain
                  forStatuses:(NSArray *)statuses
                       Offset:(NSNumber *)offset
                    OnSuccess:(void (^)(NSArray *))success
                    OnFailure:(void (^)(NSError *))failure
{
    if (!networkDomain || !userId) {
        failure([NSError errorWithDomain:kLFError code:400u userInfo:[NSDictionary dictionaryWithObject:@"Lacking necessary parameters to get user content."
                                                                                                 forKey:NSLocalizedDescriptionKey]]);
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (userToken)
        [params setObject:userToken forKey:@"lftoken"];
    if (statuses)
        [params setObject:[statuses componentsJoinedByString:@","] forKey:@"status"];
    if (offset)
        [params setObject:[offset stringValue] forKey:@"offset"];
    NSString *queryString = [[NSString alloc] initWithParams:params];
    
    NSString *host = [NSString stringWithFormat:@"%@.%@", kBootstrapDomain, networkDomain];
    NSString *path = [NSString stringWithFormat:@"/api/v3.0/author/%@/comments/%@", userId, queryString];
    
    [self requestWithHost:host
                 WithPath:path
              WithPayload:nil
               WithMethod:@"GET"
                OnSuccess:^(NSDictionary *res) {
                  NSArray *results = [res objectForKey:@"data"];
                  if (results)
                      success(results);
              }
                OnFailure:failure];
}
@end
