//
//  LFSBoostrapClient.m
//
//
//  Created by Eugene Scherba on 8/20/13.
//
//

#import "LFSBoostrapClient.h"
#import "MF_Base64Additions.h"

@interface LFSBoostrapClient ()
@end

static const NSString* const kLFSBootstrapDomain = @"bootstrap";

@implementation LFSBoostrapClient

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
                           LFSScheme, kLFSBootstrapDomain, hostname];
    
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

#pragma mark - Instance Methods
- (void)getInitForSite:(NSString *)siteId
               article:(NSString *)articleId
             onSuccess:(LFSuccessBlock)success
             onFailure:(LFFailureBlock)failure
{
    NSParameterAssert(siteId != nil);
    NSParameterAssert(articleId != nil);
    NSString* path = [NSString stringWithFormat:@"/bs3/%@/%@/%@/init",
                      _lfNetwork, siteId, [articleId base64String]];
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
                    [NSError errorWithDomain:LFSErrorDomain
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
          success:(AFSuccessBlock)success
          failure:(AFFailureBlock)failure];
}

//TODO -- move optional arguments to "parameters" dictionary argument?
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
          success:(AFSuccessBlock)success
          failure:(AFFailureBlock)failure];
}

@end
