//
//  LFSAdminClient.m
//  LFClient
//
//  Created by Eugene Scherba on 8/22/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSAdminClient.h"
#import "NSString+Base64Encoding.h"

@implementation LFSAdminClient

@synthesize lfEnvironment = _lfEnvironment;
@synthesize lfNetwork = _lfNetwork;

#pragma mark - Initialization

+ (instancetype)clientWithEnvironment:(NSString *)environment
                              network:(NSString *)network
{
    return [[self alloc] initWithEnvironment:environment network:network];
}

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@ Failed to call designated initializer. Invoke `initWithEnvironment:network:` instead.",
                                           NSStringFromClass([self class])]
                                 userInfo:nil];
}

- (id)initWithEnvironment:(NSString *)environment
                  network:(NSString *)network
{
    //NSParameterAssert(environment != nil);
    NSParameterAssert(network != nil);
    
    // cache passed parameters into readonly properties
    _lfEnvironment = environment;
    _lfNetwork = network;
    
    NSString *hostname = [network isEqualToString:@"livefyre.com"] ? environment : network;
    NSString *urlString = [NSString stringWithFormat:@"%@://%@.%@/",
                           LFSScheme, kAdminDomain, hostname];
    
    self = [super initWithBaseURL:[NSURL URLWithString:urlString]];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[LFSJSONRequestOperation class]];
    
    // Accept HTTP Header;
    // see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setParameterEncoding:AFFormURLParameterEncoding];
    return self;
}

#pragma mark - Methods

- (void)authenticateUserWithToken:(NSString *)userToken
                       collection:(NSString *)collectionId
                        onSuccess:(LFSuccessBlock)success
                        onFailure:(LFFailureBlock)failure
{
    NSParameterAssert(userToken != nil);
    NSParameterAssert(collectionId != nil);
    
    [self getPath:@"/api/v3.0/auth/"
       parameters:@{@"lftoken": userToken,
                    @"collectionId": collectionId}
          success:(AFSuccessBlock)success
          failure:(AFFailureBlock)failure];
}

- (void)authenticateUserWithToken:(NSString *)userToken
                             site:(NSString *)siteId
                          article:(NSString *)articleId
                        onSuccess:(LFSuccessBlock)success
                        onFailure:(LFFailureBlock)failure
{
    NSParameterAssert(userToken != nil);
    NSParameterAssert(siteId != nil);
    NSParameterAssert(articleId != nil);
    
    [self getPath:@"/api/v3.0/auth/"
       parameters:@{@"lftoken": userToken,
                    @"siteId": siteId,
                    @"articleId":[articleId base64EncodedString]}
          success:(AFSuccessBlock)success
          failure:(AFFailureBlock)failure];
}

@end
