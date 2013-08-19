//
//  LFAdminClient.m
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

#import "LFAdminClient.h"
#import "NSString+Base64Encoding.h"
#import "NSDictionary+QueryString.h"

@implementation LFAdminClient
+ (void)authenticateUserWithToken:(NSString *)userToken
                    forCollection:(NSString *)collectionId
                          article:(NSString *)articleId
                             site:(NSString *)siteId
                          network:(NSString *)networkDomain
                        onSuccess:(void (^)(NSDictionary *))success
                        onFailure:(void (^)(NSError *))failure
{
    NSParameterAssert(networkDomain != nil);
    NSParameterAssert(userToken != nil);
    
    NSDictionary *paramsDict;
    if (collectionId) {
        paramsDict = @{@"lftoken": userToken, @"collectionId": collectionId};
    } else {
        paramsDict = @{@"lftoken": userToken, @"siteId": siteId, @"articleId":[articleId base64EncodedString]};
    }
    
    NSString *host = [NSString stringWithFormat:@"%@.%@", kAdminDomain, networkDomain];
    NSString *path = [NSString stringWithFormat:@"/api/v3.0/auth/?%@", [paramsDict queryString]];
    
    [self requestWithHost:host
                     path:path
                   params:nil
                   method:@"GET"
                onSuccess:success
                onFailure:failure];
}
@end
