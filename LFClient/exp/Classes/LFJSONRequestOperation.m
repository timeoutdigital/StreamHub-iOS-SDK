//
//  LFJSONRequestOperation.m
//  LFClient
//
//  Created by Eugene Scherba on 8/20/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFJSONRequestOperation.h"
#import "JSONKit.h"

static dispatch_queue_t json_request_operation_processing_queue() {
    static dispatch_queue_t lf_json_request_operation_processing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lf_json_request_operation_processing_queue = dispatch_queue_create("com.alamofire.networking.json-request.processing", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return lf_json_request_operation_processing_queue;
}

@interface LFJSONRequestOperation ()
@property (readwrite, nonatomic, strong) id responseJSON;
@property (readwrite, nonatomic, strong) NSError *JSONError;
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;
@end

@implementation LFJSONRequestOperation
@synthesize responseJSON = _responseJSON;
@synthesize JSONReadingOptions = _JSONReadingOptions;
@synthesize JSONError = _JSONError;
@dynamic lock;

+ (instancetype)JSONRequestOperationWithRequest:(NSURLRequest *)urlRequest
										success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
										failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    LFJSONRequestOperation *requestOperation = [(LFJSONRequestOperation *)[self alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseJSON) {
        if (success) {
            success(operation.request, operation.response, responseJSON);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation.request, operation.response, error, [(LFJSONRequestOperation *)operation responseJSON]);
        }
    }];
    
    return requestOperation;
}

// Override responseJSON to provide customized JSON parsing
- (id)responseJSON {
    [self.lock lock];
    if (!_responseJSON && [self.responseData length] > 0 && [self isFinished] && !self.JSONError)
    {
        NSError *error = nil;
        JSONDecoder *decoder = [JSONDecoder decoderWithParseOptions:(JKParseOptionTruncateNumbers | self.JSONReadingOptions)];
        id responseJSON = [decoder objectWithData:self.responseData error:&error];
        [self setResponseJSON:responseJSON withError:error];
    }
    [self.lock unlock];
    
    return _responseJSON;
}

- (void)setResponseJSON:(id)responseJSON withError:(NSError*)error
{
    if (error) {
        self.JSONError = error;
        _responseJSON = nil;
    } else {
        [self setResponseJSON:responseJSON];
    }
}

- (void)setResponseJSON:(id)responseJSON
{
    NSInteger code = 0;
    if (!responseJSON)
    {
        // empty payload
        self.JSONError = [NSError errorWithDomain:LFSErrorDomain
                                             code:code
                                         userInfo:@{NSLocalizedDescriptionKey:@"Response failed to return data."}
                          ];
        _responseJSON = nil;
    }
    else if (![responseJSON respondsToSelector:@selector(objectForKey:)])
    {
        // payload of wrong type
        NSString *errorTemplate = @"Response was parsed as type `%@' whereas a dictionary was expected";
        NSString *errorDescription = [NSString stringWithFormat:errorTemplate,
                                      NSStringFromClass([responseJSON class])];
        self.JSONError = [NSError errorWithDomain:LFSErrorDomain
                                             code:code
                                         userInfo:@{NSLocalizedDescriptionKey:errorDescription}
                          ];
        _responseJSON = nil;
    }
    else if ([responseJSON objectForKey:@"code"] && (code = [[responseJSON objectForKey:@"code"] integerValue]) != 200)
    {
        // response code not HTTP 200
        NSString *errorTemplate = @"Response code was %d whereas code 200 was expected";
        NSString *errorMsg = [responseJSON objectForKey:@"msg"] ?: [NSString stringWithFormat:errorTemplate, code];
        self.JSONError = [NSError errorWithDomain:LFSErrorDomain
                                             code:code
                                         userInfo:@{NSLocalizedDescriptionKey:errorMsg}
                          ];
        _responseJSON = nil;
    }
    _responseJSON = responseJSON;
}

- (NSError *)error {
    if (_JSONError) {
        return _JSONError;
    } else {
        return [super error];
    }
}

#pragma mark - LFHTTPRequestOperation

+ (NSSet *)acceptableContentTypes {
    return [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
}

+ (BOOL)canProcessRequest:(NSURLRequest *)request {
    return [[[request URL] pathExtension] isEqualToString:@"json"] || [super canProcessRequest:request];
}

- (void)setCompletionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wgnu"
    
    self.completionBlock = ^ {
        if (self.error) {
            if (failure) {
                dispatch_async(self.failureCallbackQueue ?: dispatch_get_main_queue(), ^{
                    failure(self, self.error);
                });
            }
        } else {
            dispatch_async(json_request_operation_processing_queue(), ^{
                id JSON = self.responseJSON;
                
                if (self.error) {
                    if (failure) {
                        dispatch_async(self.failureCallbackQueue ?: dispatch_get_main_queue(), ^{
                            failure(self, self.error);
                        });
                    }
                } else {
                    if (success) {
                        dispatch_async(self.successCallbackQueue ?: dispatch_get_main_queue(), ^{
                            success(self, JSON);
                        });
                    }
                }
            });
        }
    };
#pragma clang diagnostic pop
}

@end
