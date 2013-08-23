//
//  LFHTTPClient.m
//
//
//  Created by Eugene Scherba on 8/20/13.
//
//

#import "LFHTTPClient.h"


@interface LFHTTPClient ()
@end

static NSString * AFBase64EncodedStringFromString(NSString *string) {
    NSData *data = [NSData dataWithBytes:[string UTF8String] length:[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        
        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}

@implementation LFHTTPClient

@synthesize lfEnvironment = _lfEnvironment;
@synthesize lfNetwork = _lfNetwork;

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
                           kLFSDKScheme, kBootstrapDomain, hostname];
    
    self = [super initWithBaseURL:[NSURL URLWithString:urlString]];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[LFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setParameterEncoding:AFFormURLParameterEncoding];
    return self;
}

- (void)getInitForSite:(NSString *)siteId
               article:(NSString *)articleId
             onSuccess:(LFSuccessBlock)success
             onFailure:(LFFailureBlock)failure
{
    NSParameterAssert(siteId != nil);
    NSParameterAssert(articleId != nil);
    NSString* path = [NSString stringWithFormat:@"/bs3/%@/%@/%@/init",
                      _lfNetwork, siteId, AFBase64EncodedStringFromString(articleId)];
    [self getPath:path
       parameters:nil
          success:(AFSuccessBlock)success
          failure:(AFFailureBlock)failure];
}

- (void)getContentWithInit:(NSDictionary *)info
                      page:(NSInteger)pageIndex
                 onSuccess:(LFSuccessBlock)success
                 onFailure:(LFFailureBlock)failure
{
    NSParameterAssert(info != nil);
    NSParameterAssert(pageIndex != NSNotFound); // is NSNotFound actually useful in this context?
    
    NSDictionary *collectionSettings = [info objectForKey:@"collectionSettings"];
    NSDictionary *archiveInfo = [collectionSettings objectForKey:@"archiveInfo"];
    
    // Note: in this SDK allow for negative indexes (for enumerating pages in reverse order)
    NSUInteger count = [[archiveInfo objectForKey:@"nPages"] unsignedIntegerValue];
    if (pageIndex < 0) {
        pageIndex += (NSInteger)count;
    }
    
    // If page index is zero we already have the content as part of the init data.
    if (pageIndex == 0) {
        NSBlockOperation *opSuccess = [[NSBlockOperation alloc] init];
        __weak NSBlockOperation *opSuccess1 = opSuccess;
        [opSuccess addExecutionBlock:^{
            success(opSuccess1,
                    [info objectForKey:@"headDocument"]
                    );
        }];
        [self.operationQueue addOperation:opSuccess];
        return;
    }
    
    if (pageIndex < 0 || pageIndex >= count) {
        // HTTP index code 416 seems to describe range error better than HTTP 400
        NSBlockOperation *opFailure = [[NSBlockOperation alloc] init];
        __weak NSBlockOperation *opFailure1 = opFailure;
        [opFailure addExecutionBlock:^{
            failure(opFailure1,
                    [NSError errorWithDomain:kLFErrorDomain
                                        code:416u
                                    userInfo:@{NSLocalizedDescriptionKey:@"Page index outside of collection page bounds."}]
                    );
        }];
        [self.operationQueue addOperation:opFailure];
        return;
    }
    
    NSString *pathBase = [archiveInfo objectForKey:@"pathBase"];
    //NSString *networkDomain = [collectionSettings objectForKey:@"networkId"];
    //NSAssert([networkDomain isEqualToString:_lfNetwork], @"Init network does not match stored network");
    
    NSString *path = [NSString stringWithFormat:@"/bs3%@%d.json", pathBase, pageIndex];
    [self getPath:path
       parameters:nil
          success:(AFSuccessBlock)success
          failure:(AFFailureBlock)failure];
}

- (void)getHottestCollectionsForSite:(NSString *)siteId
                                 tag:(NSString *)tag
                      desiredResults:(NSUInteger)number
                           onSuccess:(LFSuccessBlock)success
                           onFailure:(LFFailureBlock)failure
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (tag) {
        [parameters setObject:tag forKey:@"tag"];
    }
    if (siteId) {
        [parameters setObject:siteId forKey:@"site"];
    }
    if (number) {
        [parameters setObject:[NSNumber numberWithUnsignedInteger:number]
                       forKey:@"number"];
    }
    [self getPath:@"/api/v3.0/hottest/"
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              // TODO: figure out whether we are doing the right thing here
              id results = [responseObject objectForKey:@"data"];
              success(operation, results);
          }
          failure:(AFFailureBlock)failure];
}

- (void)getUserContentForUser:(NSString *)userId
                        token:(NSString *)userToken
                     statuses:(NSArray*)statuses
                       offset:(NSInteger)offset
                    onSuccess:(LFSuccessBlock)success
                    onFailure:(LFFailureBlock)failure
{
    NSParameterAssert(userId != nil);
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (userToken) {
        [parameters setObject:userToken forKey:@"lftoken"];
    }
    if (statuses) {
        [parameters setObject:statuses forKey:@"status"];
    }
    if (offset) {
        [parameters setObject:[NSNumber numberWithInteger:offset]
                       forKey:@"offset"];
    }
    [self getPath:[NSString stringWithFormat:@"/api/v3.0/author/%@/comments/", userId]
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              // TODO: figure out whether we are doing the right thing here
              id results = [responseObject objectForKey:@"data"];
              success(operation, results);
          }
          failure:(AFFailureBlock)failure];
}

@end
