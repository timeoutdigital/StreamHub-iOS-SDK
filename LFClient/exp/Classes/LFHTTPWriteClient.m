//
//  LFHTTPWriteClient.m
//  LFClient
//
//  Created by Eugene Scherba on 8/22/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFHTTPWriteClient.h"
#import "NSString+Base64Encoding.h"

@implementation LFHTTPWriteClient

@synthesize lfEnvironment = _lfEnvironment;
@synthesize lfNetwork = _lfNetwork;
@synthesize lfUser = _lfUser;

#pragma mark - Initialization

+ (instancetype)clientWithEnvironment:(NSString *)environment
                              network:(NSString *)network
                                 user:(NSString *)userToken
{
    return [[self alloc] initWithEnvironment:environment network:network user:userToken];
}

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@ Failed to call designated initializer. Invoke `initWithEnvironment:network:user:` instead.",
                                           NSStringFromClass([self class])]
                                 userInfo:nil];
}

- (id)initWithEnvironment:(NSString *)environment
                  network:(NSString *)network
                     user:(NSString *)userToken
{
    //NSParameterAssert(environment != nil);
    NSParameterAssert(network != nil);
    
    // cache passed parameters into readonly properties
    _lfEnvironment = environment;
    _lfNetwork = network;
    _lfUser = userToken;
    
    NSString *hostname = [network isEqualToString:@"livefyre.com"] ? environment : network;
    NSString *urlString = [NSString
                           stringWithFormat:@"%@://%@.%@/",
                           kLFSDKScheme, kQuillDomain, hostname];
    
    self = [super initWithBaseURL:[NSURL URLWithString:urlString]];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[LFJSONRequestOperation class]];
    
    // Accept HTTP Header;
    // see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setParameterEncoding:AFFormURLParameterEncoding];
    return self;
}

#pragma mark - Methods

- (void)postOpinion:(LFUserDisposition)action
         forContent:(NSString *)contentId
       inCollection:(NSString *)collectionId
          onSuccess:(LFSuccessBlock)success
          onFailure:(LFFailureBlock)failure
{
    NSParameterAssert(contentId != nil);
    
    NSString *actionEndpoint = LFUserDispositionString[action];
    NSDictionary *parameters = @{@"collection_id":collectionId,
                                 @"lftoken": _lfUser};
    NSString *path = [NSString
                      stringWithFormat:@"/api/v3.0/message/%@/%@/",
                      contentId, actionEndpoint];
    
    [self postPath:path
        parameters:parameters
           success:success
           failure:failure];
}

- (void)postFlag:(LFUserFlag)flag
      forContent:(NSString *)contentId
    inCollection:(NSString *)collectionId
      parameters:(NSDictionary*)parameters
       onSuccess:(LFSuccessBlock)success
       onFailure:(LFFailureBlock)failure
{
    NSParameterAssert(contentId != nil);
    
    NSString *flagString = LFUserFlagString[flag];
    NSMutableDictionary *parameters1 =
    [NSMutableDictionary
     dictionaryWithObjects:@[contentId, collectionId, flagString, _lfUser]
     forKeys:@[@"message_id", @"collection_id", @"flag", @"lftoken"]];
    
    // parameters passed in can be { notes: @"...", email: @"..." }
    [parameters1 addEntriesFromDictionary:parameters];
    NSString *path = [NSString
                      stringWithFormat:@"/api/v3.0/message/%@/flag/%@/",
                      contentId, flagString];
    
    [self postPath:path
        parameters:parameters1
           success:success
           failure:failure];
    
}

- (void)postContent:(NSString *)body
      forCollection:(NSString *)collectionId
          inReplyTo:(NSString *)parentId
          onSuccess:(LFSuccessBlock)success
          onFailure:(LFFailureBlock)failure
{
    NSParameterAssert(body != nil);
    NSParameterAssert(collectionId != nil);
    
    NSMutableDictionary *parameters =
    [NSMutableDictionary
     dictionaryWithObjects:@[body, _lfUser]
     forKeys:@[@"body", @"lftoken"]];
    
    if (parentId) {
        [parameters setObject:parentId forKey:@"parent_id"];
    }
    
    NSString *path = [NSString
                      stringWithFormat:@"/api/v3.0/collection/%@/post/",
                      collectionId];
    
    [self postPath:path
        parameters:parameters
           success:success
           failure:failure];
}

@end
