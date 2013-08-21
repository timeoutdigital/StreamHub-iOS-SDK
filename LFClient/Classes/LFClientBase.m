//
//  LFClientBase.m
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

#import <AFHTTPClient.h>
#import <AFHTTPRequestOperation.h>
#import "LFClientBase.h"
#import "JSONKit.h"
//#import "NSDictionary+QueryString.h"

static NSOperationQueue *_LFQueue;
static AFHTTPClient *_httpClient;

@implementation LFClientBase
//We need our own queue so that our callbacks to do not block the main queue, which executes on the main thread.
//Main thread is main.
+ (NSOperationQueue *)LFQueue
{
    if (!_LFQueue) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _LFQueue = [NSOperationQueue new];
        });
    }
    
    return _LFQueue;
}

+ (AFHTTPClient *)HTTPClientWithBaseURL:(NSURL*)baseURL
{
    if (!_httpClient) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
        });
    }
    
    if (![_httpClient.baseURL.absoluteString isEqualToString:baseURL.absoluteString]) {
        _httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    }
    return _httpClient;
}

/*
+ (void)requestWithHost:(NSString *)host
                   path:(NSString *)path
                 params:(NSDictionary *)params
                 method:(NSString *)httpMethod
              onSuccess:(void (^)(NSDictionary *res))success
              onFailure:(void (^)(NSError *))failure
{
    NSParameterAssert(host != nil);
    NSParameterAssert(path != nil);
    NSParameterAssert(httpMethod != nil);
    
    NSData *httpBody = nil;
    if (params != nil) {
        if ([httpMethod isEqualToString:@"POST"]) {
            httpBody = [params queryData];
        } else {
            path = [path stringByAppendingString:[@"?" stringByAppendingString:[params queryString]]];
        }
    }
    NSURL *connectionURL = [[NSURL alloc] initWithScheme:kLFSDKScheme host:host path:path];
    //NSLog(@"Absolute URL string: %@", [connectionURL absoluteString]);
    
    NSMutableURLRequest *connectionReq = [[NSMutableURLRequest alloc] initWithURL:connectionURL];
    [connectionReq setHTTPMethod:httpMethod];
    [connectionReq setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    if (httpBody != nil) {
        [connectionReq setHTTPBody:httpBody];
    }
    
    [NSURLConnection sendAsynchronousRequest:connectionReq
                                       queue:[self LFQueue]
                           completionHandler:^(NSURLResponse *resp, NSData *data, NSError *err) {
        NSDictionary *payload = [self handleResponse:resp error:err data:data onFailure:failure];
        if (payload) {
            success(payload);
        }
        return;
    }];
} */


+ (void)requestWithHost:(NSString *)host
                   path:(NSString *)path
                 params:(NSDictionary *)params
                 method:(NSString *)httpMethod
              onSuccess:(void (^)(NSDictionary *res))success
              onFailure:(void (^)(NSError *))failure
{
    NSParameterAssert(host != nil);
    NSParameterAssert(path != nil);
    NSParameterAssert(httpMethod != nil);
    
    NSURL *url = [[NSURL alloc] initWithScheme:kLFSDKScheme host:host path:@"/"];
    NSMutableURLRequest *request = [[self HTTPClientWithBaseURL:url] requestWithMethod:httpMethod
                                                                                  path:path
                                                                            parameters:params];
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[self LFQueue]
                           completionHandler:^(NSURLResponse *resp, NSData *data, NSError *err) {
                               NSDictionary *payload = [self handleResponse:resp error:err data:data onFailure:failure];
                               if (payload) {
                                   success(payload);
                               }
                               return;
                           }];
}

+ (NSDictionary *)handleResponse:(NSURLResponse *)resp
                           error:(NSError *)err
                            data:(NSData *)data
                       onFailure:(void (^)(NSError *))failure
{
    NSParameterAssert(resp != nil);
    
    if (err) {
        // NSURLConnection error
        failure(err);
        return nil;
    }
    
    NSError *error = nil;
    
    //id payload = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    JSONDecoder *decoder = [JSONDecoder decoderWithParseOptions:JKParseOptionTruncateNumbers];
    id payload = [decoder objectWithData:data error:&error];
    
    /*
     //bad news bears
     if (error && error.code == 3840u) {
     payload = [self handleNaNBugWithData:data];
     if (payload)
     return payload;
     }
     */
    
    NSInteger code = 0;
    if (error)
    {
        // parse error
        failure(error);
        return nil;
    }
    else if (!payload)
    {
        // empty payload
        failure([NSError errorWithDomain:kLFError
                                    code:code
                                userInfo:@{NSLocalizedDescriptionKey:@"Response failed to return data."}
                 ]);
        return nil;
    }
    else if (![payload respondsToSelector:@selector(objectForKey:)])
    {
        // payload of wrong type
        NSString *errorTemplate = @"Response was parsed as type %@ whereas NSDictionary was expected";
        NSString *errorDescription = [NSString stringWithFormat:errorTemplate,
                                      NSStringFromClass([payload class])];
        failure([NSError errorWithDomain:kLFError
                                    code:code
                                userInfo:@{NSLocalizedDescriptionKey:errorDescription}
                 ]);
        return nil;
    }
    else if ([payload objectForKey:@"code"] && (code = [[payload objectForKey:@"code"] integerValue]) != 200)
    {
        // response code not HTTP 200
        failure([NSError errorWithDomain:kLFError
                                    code:code
                                userInfo:@{NSLocalizedDescriptionKey:[payload objectForKey:@"msg"]}
                 ]);
        return nil;
    }
    
    return payload;
}

@end
