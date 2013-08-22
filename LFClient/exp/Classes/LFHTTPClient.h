//
//  LFHTTPClient.h
//  
//
//  Created by Eugene Scherba on 8/20/13.
//
//

#import "AFHTTPClient.h"
#import "LFJSONRequestOperation.h"

typedef void (^LFSuccessBlock) (LFJSONRequestOperation *operation, id responseObject);
typedef void (^LFFailureBlock) (LFJSONRequestOperation *operation, NSError *error);
typedef void (^AFSuccessBlock) (AFHTTPRequestOperation *operation, id responseObject);
typedef void (^AFFailureBlock) (AFHTTPRequestOperation *operation, NSError *error);

@interface LFHTTPClient : AFHTTPClient

- (id)initWithEnvironment:(NSString *)environment
                  network:(NSString *)network;

- (void)getInitForSite:(NSString *)site
               article:(NSString *)articleId
             onSuccess:(LFSuccessBlock)success
             onFailure:(LFFailureBlock)failure;

@property (nonatomic, readonly, strong) NSString* lfEnvironment;
@property (nonatomic, readonly, strong) NSString* lfNetwork;

@end
