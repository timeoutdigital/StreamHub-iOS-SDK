//
//  LFSBaseClient.h
//  LFSClient
//
//  Created by Eugene Scherba on 8/27/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <AFNetworking/AFHTTPClient.h>
#import "LFSConstants.h"
#import "LFSJSONRequestOperation.h"
#import "JSONKit.h"

@interface LFSBaseClient : AFHTTPClient

/**
  @property lfEnvironment Environment with which this class instance was initialized
 */
@property (nonatomic, readonly, strong) NSString* lfEnvironment;

/**
 @property lfNetwork Network with which this class instance was initialized
 */
@property (nonatomic, readonly, strong) NSString* lfNetwork;

/**
 @property subdomain abstract (to be overriden) subdomain of the baseURL
 */
@property (nonatomic, readonly, strong) NSString *subdomain;


/**
 * Initialize Livefyre client
 *
 * @param networkDomain network as identified by domain, i.e. livefyre.com.
 * @param environment (optional) Where collection(s) are hosted, i.e. t-402.
 *        Used for development/testing purposes.
 * @return LFSClient instance
 * @see -initWithEnvironment:network:
 */

+ (instancetype)clientWithNetwork:(NSString *)network
                      environment:(NSString *)environment;

/**
 * Initialize Livefyre client
 *
 * @param networkDomain network as identified by domain, i.e. livefyre.com.
 * @param environment (optional) Where collection(s) are hosted, i.e. t-402.
 *        Used for development/testing purposes.
 * @return LFSClient instance
 */
- (instancetype)initWithNetwork:(NSString *)network
                    environment:(NSString *)environment;


/**
 Creates an `LFSJSONRequestOperation` with a `POST` request, and enqueues it to the HTTP client's operation queue.
 
 @param path The path to be appended to the HTTP client's base URL and used as the request URL.
 @param parameters The parameters to be encoded and set in the request HTTP body.
 @param parameterEncoding The `AFHTTPClientParameterEncoding` value corresponding to how parameters are encoded into a request body
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes two arguments: the created request operation and the object created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 
 @see -HTTPRequestOperationWithRequest:success:failure:
 */
- (void)postURL:(NSURL *)url
     parameters:(NSDictionary *)parameters
parameterEncoding:(AFHTTPClientParameterEncoding)parameterEncoding
        success:(AFSuccessBlock)success
        failure:(AFFailureBlock)failure;

@end
