//
//  LFSWriteClient.m
//  LFClient
//
//  Created by Eugene Scherba on 8/22/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSWriteClient.h"
#import "MF_Base64Additions.h"
#import "JSONKit.h"
#import "JWT.h"
#import "NSString+Hashes.h"

static const NSString *const kLFSQuillDomain = @"quill";

static const NSString* const LFSOpinionString[] = {
    @"like",
    @"unlike"
};

static const NSString* const LFSUserFlagString[] = {
    @"offensive",
    @"spam",
    @"disagree",
    @"off-topic"
};

@interface LFSWriteClient ()
@property (readwrite, nonatomic, strong) NSMutableDictionary *defaultHeaders;
@end

@implementation LFSWriteClient

@dynamic defaultHeaders;

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
                                   reason:[NSString stringWithFormat:@"%@ Failed to call designated initializer. Invoke `initWithEnvironment:network:user:` instead.",
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
    NSString *urlString = [NSString
                           stringWithFormat:@"%@://%@.%@/api/v3.0/",
                           LFSScheme, kLFSQuillDomain, hostname];
    
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

- (void)postOpinion:(LFSOpinion)action
            forUser:(NSString*)userToken
         forContent:(NSString *)contentId
       inCollection:(NSString *)collectionId
          onSuccess:(LFSuccessBlock)success
          onFailure:(LFFailureBlock)failure
{
    NSParameterAssert(contentId != nil);
    
    const NSString *actionEndpoint = LFSOpinionString[action];
    NSDictionary *parameters = @{@"collection_id":collectionId,
                                 @"lftoken": userToken};
    NSString *path = [NSString
                      stringWithFormat:@"message/%@/%@/",
                      contentId, actionEndpoint];
    
    [self postPath:path
        parameters:parameters
           success:success
           failure:failure];
}

- (void)postFlag:(LFSUserFlag)flag
         forUser:(NSString*)userToken
      forContent:(NSString *)contentId
    inCollection:(NSString *)collectionId
      parameters:(NSDictionary*)parameters
       onSuccess:(LFSuccessBlock)success
       onFailure:(LFFailureBlock)failure
{
    NSParameterAssert(contentId != nil);
    
    const NSString *flagString = LFSUserFlagString[flag];
    NSMutableDictionary *parameters1 =
    [NSMutableDictionary
     dictionaryWithObjects:@[contentId, collectionId, flagString, userToken]
     forKeys:@[@"message_id", @"collection_id", @"flag", @"lftoken"]];
    
    // parameters passed in can be { notes: @"...", email: @"..." }
    [parameters1 addEntriesFromDictionary:parameters];
    NSString *path = [NSString
                      stringWithFormat:@"message/%@/flag/%@/",
                      contentId, flagString];
    
    [self postPath:path
        parameters:parameters1
           success:success
           failure:failure];
    
}

- (void)postContent:(NSString *)body
            forUser:(NSString*)userToken
      forCollection:(NSString *)collectionId
          inReplyTo:(NSString *)parentId
          onSuccess:(LFSuccessBlock)success
          onFailure:(LFFailureBlock)failure
{
    NSParameterAssert(body != nil);
    NSParameterAssert(collectionId != nil);
    
    NSMutableDictionary *parameters =
    [NSMutableDictionary
     dictionaryWithObjects:@[body, userToken]
     forKeys:@[@"body", @"lftoken"]];
    
    if (parentId) {
        [parameters setObject:parentId forKey:@"parent_id"];
    }
    
    NSString *path = [NSString
                      stringWithFormat:@"collection/%@/post/",
                      collectionId];
    
    [self postPath:path
        parameters:parameters
           success:success
           failure:failure];
}

- (void)createCollection:(NSString *)articleId
                  forSite:(NSString*)siteId
                 siteKey:(NSString*)siteKey
                   title:(NSString*)title
                 withURL:(NSURL *)url
                    tags:(NSArray*)tagArray
               onSuccess:(LFSuccessBlock)success
               onFailure:(LFFailureBlock)failure
{
    NSParameterAssert(siteId != nil);
    NSParameterAssert([title length] <= 255);
    NSParameterAssert([articleId length] <= 255);
    
    // JSON-encode and concatenate tag array
    NSMutableArray *encodedTags = [NSMutableArray arrayWithCapacity:[tagArray count]];
    for (NSString *tag in tagArray) {
        [encodedTags addObject:[tag JSONString]];
    }
    NSString *urlString = url ? [url absoluteString] : @"";
    NSString *collectionMeta = [JWT encodePayload:@{@"title":[title JSONString],
                                                    @"url":urlString,
                                                    @"tags":[encodedTags componentsJoinedByString:@","],
                                                    @"articleId":[articleId JSONString]}
                                       withSecret:siteKey];
    NSString *checksum = [collectionMeta md5];
    NSDictionary *parameters = @{@"collectionMeta": collectionMeta, @"checksum": checksum};
    
    NSString *path = [NSString
                      stringWithFormat:@"site/%@/collection/create",
                      siteId];
    
    [self postPath:path
        parameters:parameters
 parameterEncoding:AFJSONParameterEncoding
           success:success
           failure:failure];
}

// extend standard operation to parametrize by parameter encoding
- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
parameterEncoding:(AFHTTPClientParameterEncoding)parameterEncoding
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	NSURLRequest *request = [self requestWithMethod:@"POST"
                                               path:path
                                         parameters:parameters
                                  parameterEncoding:parameterEncoding];
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:success
                                                                      failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

// extend standard operation to parametrize by parameter encoding
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters
                         parameterEncoding:(AFHTTPClientParameterEncoding)parameterEncoding
{
    NSParameterAssert(method);
    
    if (!path) {
        path = @"";
    }
    
    NSURL *url = [NSURL URLWithString:path relativeToURL:self.baseURL];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:method];
    [request setAllHTTPHeaderFields:self.defaultHeaders];
    
    if (parameters) {
        if ([method isEqualToString:@"GET"] || [method isEqualToString:@"HEAD"] || [method isEqualToString:@"DELETE"]) {
            url = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat:[path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", AFQueryStringFromParametersWithEncoding(parameters, self.stringEncoding)]];
            [request setURL:url];
        } else {
            NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(self.stringEncoding));
            NSError *error = nil;
            
            switch (parameterEncoding) {
                case AFFormURLParameterEncoding:;
                    [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[AFQueryStringFromParametersWithEncoding(parameters, self.stringEncoding) dataUsingEncoding:self.stringEncoding]];
                    break;
                case AFJSONParameterEncoding:;
                    [request setValue:[NSString stringWithFormat:@"application/json; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wassign-enum"
                    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error]];
#pragma clang diagnostic pop
                    break;
                case AFPropertyListParameterEncoding:;
                    [request setValue:[NSString stringWithFormat:@"application/x-plist; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[NSPropertyListSerialization dataWithPropertyList:parameters format:NSPropertyListXMLFormat_v1_0 options:0 error:&error]];
                    break;
            }
            
            if (error) {
                NSLog(@"%@ %@: %@", [self class], NSStringFromSelector(_cmd), error);
            }
        }
    }
	return request;
}

@end
