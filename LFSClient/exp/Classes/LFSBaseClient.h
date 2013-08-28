//
//  LFSBaseClient.h
//  LFSClient
//
//  Created by Eugene Scherba on 8/27/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "lftypes.h"
#import "AFHTTPClient.h"
#import "LFSJSONRequestOperation.h"
#import "JSONKit.h"

@interface LFSBaseClient : AFHTTPClient

@property (nonatomic, readonly, strong) NSString* lfEnvironment;
@property (nonatomic, readonly, strong) NSString* lfNetwork;

/**
 * Initialize Livefyre client
 *
 * @param networkDomain network as identified by domain, i.e. livefyre.com.
 * @param environment (optional) Where collection(s) are hosted, i.e. t-402. 
 *        Used for development/testing purposes.
 * @return LFSClient instance
 */

+ (instancetype)clientWithEnvironment:(NSString *)environment
                              network:(NSString *)network;

- (id)initWithEnvironment:(NSString *)environment
                  network:(NSString *)network;


// abstract (to be overriden) subdomain of the baseURL
@property (nonatomic, readonly, strong) NSString *subdomain;

- (void)postURL:(NSURL *)url
     parameters:(NSDictionary *)parameters
parameterEncoding:(AFHTTPClientParameterEncoding)parameterEncoding
        success:(AFSuccessBlock)success
        failure:(AFFailureBlock)failure;

@end
