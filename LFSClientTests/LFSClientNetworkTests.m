//
//  LFSClientTests.m
//  LFSClientTests
//
//  Created by zjj on 1/14/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
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


#import <XCTest/XCTest.h>
#import <Base64/MF_Base64Additions.h>
#import <AFHTTPRequestOperationLogger/AFHTTPRequestOperationLogger.h>

#import "LFSClient.h"
#import "LFSConfig.h"
#import "LFSStreamClient.h"
#import "LFSBootstrapClient.h"
#import "LFSAdminClient.h"
#import "LFSWriteClient.h"

#define EXP_SHORTHAND YES
#import <Expecta/Expecta.h>

@interface LFSClientNetworkTests : XCTestCase
@end

@implementation LFSClientNetworkTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    if (![LFSConfig objectForKey:@"domain"]) {
        XCTFail(@"No test settings");
    }
    
    [[AFHTTPRequestOperationLogger sharedLogger] startLogging];
    
    // set timeout to 60 seconds
    [Expecta setAsynchronousTestTimeout:600.0f];
}

- (void)tearDown
{
    // Tear-down code here.
    [[AFHTTPRequestOperationLogger sharedLogger] stopLogging];
    
    [super tearDown];
}

#pragma mark - Get init


- (void)testInitWithLFJSONRequestOperation
{
    // Requires HTTP request encoding
    
    __block id result = nil;
    
    // Most complicated way to use LFHTTPClient... Nevertheless it should work
    NSString* path = [NSString stringWithFormat:@"bs3/%@/%@/%@/init",
                      [LFSConfig objectForKey:@"domain"],
                      [LFSConfig objectForKey:@"site"],
                      [[LFSConfig objectForKey:@"article"] base64String]];

    LFSBootstrapClient *client = [LFSBootstrapClient
                                  clientWithNetwork:[LFSConfig objectForKey:@"domain"]
                                  environment:[LFSConfig objectForKey:@"environment"]];

    AFHTTPRequestSerializer* requestSerializer =
     [client.requestSerializers objectForKey:[NSNumber numberWithInteger:AFFormURLParameterEncoding]];

    NSString *fullPath = [[client.reqOpManager.baseURL URLByAppendingPathComponent:path] absoluteString];
    NSURLRequest *request = [requestSerializer requestWithMethod:@"GET"
                                                       URLString:fullPath
                                                      parameters:nil
                                                           error:nil];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = client.responseSerializer;
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        result = responseObject;
    }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"Error code %zd, with recovery suggestion: %@",
              error.code, [error localizedRecoverySuggestion]);
    }];
    [client.reqOpManager.operationQueue addOperation:op];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    if (op) {
        expect(op.error).notTo.equal(NSURLErrorTimedOut);
        expect(op.response.statusCode).to.equal(200);
    }
    
    if (op.error != nil) {
        XCTFail(@"%@: %@", [op.error localizedDescription], [op.error localizedRecoverySuggestion]);
    }
    expect(result).will.beTruthy();
    if (result) {
        expect(result).to.beKindOf([NSDictionary class]);
        expect([result allKeys]).to.beSupersetOf(@[@"networkSettings", @"headDocument", @"collectionSettings", @"siteSettings"]);
    }
}


- (void)testInitWithGetPath
{
    __block AFHTTPRequestOperation *op = nil;
    __block id result = nil;
    
    // Second easiest way to use LFHTTPClient
    NSString* path = [NSString stringWithFormat:@"bs3/%@/%@/%@/init",
                      [LFSConfig objectForKey:@"domain"],
                      [LFSConfig objectForKey:@"site"],
                      [[LFSConfig objectForKey:@"article"] base64String]];
    
    LFSBootstrapClient *client = [LFSBootstrapClient
                                  clientWithNetwork:[LFSConfig objectForKey:@"domain"]
                                  environment:[LFSConfig objectForKey:@"environment"]];

    [client getPath:path
         parameters:nil
  parameterEncoding:AFFormURLParameterEncoding
            success:^(AFHTTPRequestOperation *operation, id JSON){
                op = operation;
                result = JSON;
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                op = operation;
                NSLog(@"Error code %zd, with recovery suggestion: %@",
                      error.code, [error localizedRecoverySuggestion]);
            }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    if (op) {
        expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
        expect(op.error).notTo.equal(NSURLErrorTimedOut);
    }

    if (op.error != nil) {
        XCTFail(@"%@: %@", [op.error localizedDescription], [op.error localizedRecoverySuggestion]);
    }
    expect(result).will.beTruthy();
    if (result) {
        expect(result).to.beKindOf([NSDictionary class]);
        expect([result allKeys]).to.beSupersetOf(@[@"networkSettings", @"headDocument", @"collectionSettings", @"siteSettings"]);
    }
}

- (void)testInitWithGetInitForArticle
{
    //Note: this test fails when the URL is wrong (the way it's meant to be)
    __block AFHTTPRequestOperation *op = nil;
    __block id result = nil;
    
    // This is the easiest way to use LFHTTPClient
    LFSBootstrapClient *client = [LFSBootstrapClient
                                  clientWithNetwork:[LFSConfig objectForKey:@"domain"]
                                  environment:[LFSConfig objectForKey:@"environment"]];
    [client getInitForSite:[LFSConfig objectForKey:@"site"]
                   article:[LFSConfig objectForKey:@"article"]
                 onSuccess:^(NSOperation *operation, id JSON){
                     op = (AFHTTPRequestOperation*)operation;
                     result = JSON;
                 }
                 onFailure:^(NSOperation *operation, NSError *error) {
                     op = (AFHTTPRequestOperation*)operation;
                     NSLog(@"Error code %zd, with recovery suggestion: %@",
                           error.code, [error localizedRecoverySuggestion]);
                 }
     ];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    if (op) {
        expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
        expect(op.error).notTo.equal(NSURLErrorTimedOut);
    }

    if (op.error != nil) {
        XCTFail(@"%@: %@", [op.error localizedDescription], [op.error localizedRecoverySuggestion]);
    }
    expect(result).will.beTruthy();
    if (result) {
        expect(result).to.beKindOf([NSDictionary class]);
        expect([result allKeys]).to.beSupersetOf(@[@"networkSettings", @"headDocument", @"collectionSettings", @"siteSettings"]);
    }
}

- (void)testFeaturedWithGetFeaturedForArticle
{
    //Note: this test fails when the URL is wrong (the way it's meant to be)
    __block AFHTTPRequestOperation *op = nil;
    __block id result = nil;
    
    // This is the easiest way to use LFHTTPClient
    LFSBootstrapClient *client = [LFSBootstrapClient
                                  clientWithNetwork:[LFSConfig objectForKey:@"domain"]
                                  environment:[LFSConfig objectForKey:@"environment"]];
    
    [client getFeaturedForSite:[LFSConfig objectForKey:@"site"]
                       article:[LFSConfig objectForKey:@"article"]
                          head:YES
                     onSuccess:^(NSOperation *operation, id JSON){
                     op = (AFHTTPRequestOperation*)operation;
                     result = JSON;
                 }
                 onFailure:^(NSOperation *operation, NSError *error) {
                     op = (AFHTTPRequestOperation*)operation;
                     NSLog(@"Error code %zd, with recovery suggestion: %@",
                           error.code, [error localizedRecoverySuggestion]);
                 }
     ];

    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    if (op) {
        expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
        expect(op.error).notTo.equal(NSURLErrorTimedOut);
    }

    if (op.error != nil) {
        XCTFail(@"%@: %@", [op.error localizedDescription], [op.error localizedRecoverySuggestion]);
    }
    expect(result).will.beTruthy();
    if (result) {
        expect(result).to.beKindOf([NSDictionary class]);
        expect([result allKeys]).to.beSupersetOf(@[@"content", @"authors", @"size", @"isComplete"]);
    }
}

- (void)testReviewInitWithGetInitForArticle
{
    //Note: this test fails when the URL is wrong (the way it's meant to be)
    __block AFHTTPRequestOperation *op = nil;
    __block id result = nil;
    
    // This is the easiest way to use LFHTTPClient
    LFSBootstrapClient *client = [LFSBootstrapClient
                                  clientWithNetwork:[LFSConfig objectForKey:@"domain"]
                                  environment:[LFSConfig objectForKey:@"environment"]];
    [client getInitForSite:[LFSConfig objectForKey:@"liveReviewSite"]
                   article:[LFSConfig objectForKey:@"liveReviewArticle"]
                 onSuccess:^(NSOperation *operation, id JSON){
                     op = (AFHTTPRequestOperation*)operation;
                     result = JSON;
                 }
                 onFailure:^(NSOperation *operation, NSError *error) {
                     op = (AFHTTPRequestOperation*)operation;
                     NSLog(@"Error code %zd, with recovery suggestion: %@",
                           error.code, [error localizedRecoverySuggestion]);
                 }
     ];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    if (op) {
        expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
        expect(op.error).notTo.equal(NSURLErrorTimedOut);
    }

    if (op.error != nil) {
        XCTFail(@"%@: %@", [op.error localizedDescription], [op.error localizedRecoverySuggestion]);
    }
    expect(result).will.beTruthy();
    if (result) {
        expect(result).to.beKindOf([NSDictionary class]);
        expect([result allKeys]).to.beSupersetOf(@[@"networkSettings", @"headDocument", @"collectionSettings", @"siteSettings"]);
    }
}

#pragma mark - Retrieve Hottest Collections
- (void)testHeatAPIWithGetHottestCollections
{
    //Note: this test fails when the URL is wrong (the way it's meant to be)
    __block AFHTTPRequestOperation *op = nil;
    __block NSArray *result = nil;
    
    // Actual call would look something like this:
    LFSBootstrapClient *client = [LFSBootstrapClient
                                  clientWithNetwork:[LFSConfig objectForKey:@"domain"]
                                  environment:[LFSConfig objectForKey:@"environment"]];
    [client getHottestCollectionsForSite:[LFSConfig objectForKey:@"site"]
                                     tag:@"tag"
                          desiredResults:10u
                               onSuccess:^(NSOperation *operation, id responseObject) {
                                   op = (AFHTTPRequestOperation *)operation;
                                   result = (NSArray *)responseObject;
                               } onFailure:^(NSOperation *operation, NSError *error) {
                                   op = (AFHTTPRequestOperation *)operation;
                                   NSLog(@"Error code %zd, with recovery suggestion: %@",
                                         error.code, [error localizedRecoverySuggestion]);
                               }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    if (op) {
        expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
        expect(op.error).notTo.equal(NSURLErrorTimedOut);
    }
    if (op.error != nil) {
        XCTFail(@"%@: %@", [op.error localizedDescription], [op.error localizedRecoverySuggestion]);
    }
    expect(result).will.beTruthy();
}

#pragma mark - Retrieve User Data
- (void)testUserDataRetrieval
{
    //Note: this test fails when the URL is wrong (the way it's meant to be)
    __block AFHTTPRequestOperation *op = nil;
    __block NSArray *result = nil;
    
    // Actual call would look something like this:
    LFSBootstrapClient *clientLabs = [LFSBootstrapClient
                                      clientWithNetwork:[LFSConfig objectForKey:@"labs network"]
                                      environment:[LFSConfig objectForKey:@"environment"]];
    [clientLabs getUserContentForUser:[LFSConfig objectForKey:@"system user"]
                                token:nil
                             statuses:nil
                               offset:0
                            onSuccess:^(NSOperation *operation, id responseObject) {
                                op = (AFHTTPRequestOperation *)operation;
                                result = (NSArray *)responseObject;
                            } onFailure:^(NSOperation *operation, NSError *error) {
                                op = (AFHTTPRequestOperation *)operation;
                                NSLog(@"Error code %zd, with recovery suggestion: %@",
                                      error.code, [error localizedRecoverySuggestion]);
                            }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    if (op) {
        expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
        expect(op.error).notTo.equal(NSURLErrorTimedOut);
    }
    if (op.error != nil) {
        XCTFail(@"%@: %@", [op.error localizedDescription], [op.error localizedRecoverySuggestion]);
    }
    expect(result).will.beTruthy();
}

#pragma mark - Test user authentication
- (void)testUserAuthenticationSiteArticle {
    //with collection id
    __block AFHTTPRequestOperation *op = nil;
    __block NSDictionary *result = nil;
    
    NSString *userToken = [LFSConfig objectForKey:@"moderator user auth token"];
    
    LFSAdminClient *clientAdmin = [LFSAdminClient
                                   clientWithNetwork:[LFSConfig objectForKey:@"domain"]
                                   environment:nil ];
    [clientAdmin authenticateUserWithToken:userToken
                                      site:[LFSConfig objectForKey:@"site"]
                                   article:[LFSConfig objectForKey:@"article"]
                                 onSuccess:^(NSOperation *operation, id responseObject) {
                                     op = (AFHTTPRequestOperation *)operation;
                                     result = (NSDictionary *)responseObject;
                                 }
                                 onFailure:^(NSOperation *operation, NSError *error) {
                                     op = (AFHTTPRequestOperation *)operation;
                                     NSLog(@"Error code %zd, with recovery suggestion: %@",
                                           error.code, [error localizedRecoverySuggestion]);
                                 }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    if (op) {
        expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
        expect(op.error).notTo.equal(NSURLErrorTimedOut);
    }
    if (op.error != nil) {
        XCTFail(@"%@: %@", [op.error localizedDescription], [op.error localizedRecoverySuggestion]);
    }
    expect(result).will.beTruthy();
    if (result) {
        expect(result).to.beKindOf([NSDictionary class]);
        expect([result valueForKeyPath:@"auth_token.value"]).to.equal(userToken);
    }
}

- (void)testUserAuthenticationCollection {
    //with collection id
    __block AFHTTPRequestOperation *op = nil;
    __block NSDictionary *result = nil;
    
    NSString *userToken = [LFSConfig objectForKey:@"moderator user auth token"];
    
    LFSAdminClient *clientAdmin = [LFSAdminClient
                                   clientWithNetwork:[LFSConfig objectForKey:@"domain"]
                                   environment:nil ];
    [clientAdmin authenticateUserWithToken:userToken
                                collection:[LFSConfig objectForKey:@"collection"]
                                 onSuccess:^(NSOperation *operation, id responseObject) {
                                     op = (AFHTTPRequestOperation *)operation;
                                     result = (NSDictionary *)responseObject;
                                 }
                                 onFailure:^(NSOperation *operation, NSError *error) {
                                     op = (AFHTTPRequestOperation *)operation;
                                     NSLog(@"Error code %zd, with recovery suggestion: %@",
                                           error.code, [error localizedRecoverySuggestion]);
                                 }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    if (op) {
        expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
        expect(op.error).notTo.equal(NSURLErrorTimedOut);
    }
    if (op.error != nil) {
        XCTFail(@"%@: %@", [op.error localizedDescription], [op.error localizedRecoverySuggestion]);
    }
    expect(result).will.beTruthy();
    if (result) {
        expect(result).to.beKindOf([NSDictionary class]);
        expect([result valueForKeyPath:@"auth_token.value"]).to.equal(userToken);
    }
}

#pragma mark -
- (void)testFlagAuthor {
    //with collection id
    __block AFHTTPRequestOperation *op = nil;
    __block NSDictionary *result = nil;
    
    LFSWriteClient *clientWrite = [LFSWriteClient
                                   clientWithNetwork:[LFSConfig objectForKey:@"domain"]
                                   environment:nil ];
    
    NSString *userId = [LFSConfig objectForKey:@"domain user id"];
    NSString *site = [LFSConfig objectForKey:@"site"];
    NSString *moderatorToken = [LFSConfig objectForKey:@"moderator user auth token"];
    
    // Step 1: ban user
    [clientWrite flagAuthor:userId
                     action:LFSAuthorActionBan
                   forSites:site
                retroactive:NO
                  userToken:moderatorToken
                  onSuccess:^(NSOperation *operation, id responseObject) {
                      op = (AFHTTPRequestOperation *)operation;
                      result = (NSDictionary *)responseObject;
                  }
                  onFailure:^(NSOperation *operation, NSError *error) {
                      op = (AFHTTPRequestOperation *)operation;
                      NSLog(@"Error code %zd, with recovery suggestion: %@",
                            error.code, [error localizedRecoverySuggestion]);
                  }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    if (op) {
        expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
        expect(op.error).notTo.equal(NSURLErrorTimedOut);
    }
    if (op.error != nil) {
        XCTFail(@"%@: %@", [op.error localizedDescription], [op.error localizedRecoverySuggestion]);
    }
    expect(result).will.beTruthy();
    if (result) {
        expect(result).to.beKindOf([NSDictionary class]);
        expect([result objectForKey:@"message"]).to.equal(@"Success");
    }
    
    op = nil;
    result = nil;
    
    // Step 2: unban user
    [clientWrite flagAuthor:userId
                     action:LFSAuthorActionUnban
                   forSites:site
                retroactive:NO
                  userToken:moderatorToken
                  onSuccess:^(NSOperation *operation, id responseObject) {
                      op = (AFHTTPRequestOperation *)operation;
                      result = (NSDictionary *)responseObject;
                  }
                  onFailure:^(NSOperation *operation, NSError *error) {
                      op = (AFHTTPRequestOperation *)operation;
                      NSLog(@"Error code %zd, with recovery suggestion: %@",
                            error.code, [error localizedRecoverySuggestion]);
                  }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    if (op) {
        expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
        expect(op.error).notTo.equal(NSURLErrorTimedOut);
    }
    if (op.error != nil) {
        XCTFail(@"%@: %@", [op.error localizedDescription], [op.error localizedRecoverySuggestion]);
    }
    expect(result).will.beTruthy();
    if (result) {
        expect(result).to.beKindOf([NSDictionary class]);
        expect([result objectForKey:@"message"]).to.equal(@"Success");
    }
}

#pragma mark - test opines
- (void)testLikes {
    
    // Requires HTTP request encoding
    
    __block AFHTTPRequestOperation *op = nil;
    __block NSDictionary *result = nil;
    
    LFSWriteClient *clientWrite = [LFSWriteClient
                                   clientWithNetwork:[LFSConfig objectForKey:@"domain"]
                                   environment:nil ];
    [clientWrite postMessage:LFSMessageLike
                  forContent:[LFSConfig objectForKey:@"content"]
                inCollection:[LFSConfig objectForKey:@"collection"]
                   userToken:[LFSConfig objectForKey:@"moderator user auth token"]
                  parameters:nil
                   onSuccess:^(NSOperation *operation, id responseObject) {
                       op = (AFHTTPRequestOperation *)operation;
                       result = (NSDictionary *)responseObject;
                   }
                   onFailure:^(NSOperation *operation, NSError *error) {
                       op = (AFHTTPRequestOperation *)operation;
                       NSLog(@"Error code %zd, with recovery suggestion: %@",
                             error.code, [error localizedRecoverySuggestion]);
                   }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    if (op) {
        expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
        expect(op.error).notTo.equal(NSURLErrorTimedOut);
    }
    if (op.error != nil) {
        XCTFail(@"%@: %@", [op.error localizedDescription], [op.error localizedRecoverySuggestion]);
    }
    expect(result).will.beTruthy();
}

- (void)testUnlikes {
    
    // Requires HTTP request encoding
    
    __block AFHTTPRequestOperation *op = nil;
    __block NSDictionary *result = nil;
    
    LFSWriteClient *clientWrite = [LFSWriteClient
                                   clientWithNetwork:[LFSConfig objectForKey:@"domain"]
                                   environment:nil ];
    [clientWrite postMessage:LFSMessageUnlike
                  forContent:[LFSConfig objectForKey:@"content"]
                inCollection:[LFSConfig objectForKey:@"collection"]
                   userToken:[LFSConfig objectForKey:@"moderator user auth token"]
                  parameters:nil
                   onSuccess:^(NSOperation *operation, id responseObject) {
                       op = (AFHTTPRequestOperation *)operation;
                       result = (NSDictionary *)responseObject;
                   }
                   onFailure:^(NSOperation *operation, NSError *error) {
                       op = (AFHTTPRequestOperation *)operation;
                       NSLog(@"Error code %zd, with recovery suggestion: %@",
                             error.code, [error localizedRecoverySuggestion]);
                   }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    if (op) {
        expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
        expect(op.error).notTo.equal(NSURLErrorTimedOut);
    }
    if (op.error != nil) {
        XCTFail(@"%@: %@", [op.error localizedDescription], [op.error localizedRecoverySuggestion]);
    }
    expect(result).will.beTruthy();
}

- (void)testFeature {
    
    // Requires HTTP request encoding
    
    __block AFHTTPRequestOperation *op = nil;
    __block NSDictionary *result = nil;
    
    LFSWriteClient *clientWrite = [LFSWriteClient
                                   clientWithNetwork:[LFSConfig objectForKey:@"domain"]
                                   environment:nil ];
    
    [clientWrite feature:YES
                 comment:[LFSConfig objectForKey:@"content"]
            inCollection:[LFSConfig objectForKey:@"collection"]
               userToken:[LFSConfig objectForKey:@"moderator user auth token"]
               onSuccess:^(NSOperation *operation, id responseObject) {
                           op = (AFHTTPRequestOperation *)operation;
                           result = (NSDictionary *)responseObject;
                       }
                       onFailure:^(NSOperation *operation, NSError *error) {
                           op = (AFHTTPRequestOperation *)operation;
                           NSLog(@"Error code %zd, with recovery suggestion: %@",
                                 error.code, [error localizedRecoverySuggestion]);
                       }];

    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    if (op) {
        expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
        expect(op.error).notTo.equal(NSURLErrorTimedOut);
    }
    if (op.error != nil) {
        XCTFail(@"%@: %@", [op.error localizedDescription], [op.error localizedRecoverySuggestion]);
    }
    expect(result).will.beTruthy();
}


#pragma mark - test posts
- (void)testPostAndDelete
{
    
    // Requires HTTP request encoding
    
    //Note: this test fails when the URL is wrong (the way it's meant to be)
    __block AFHTTPRequestOperation *op = nil;
    __block id result = nil;
    
    // Actual call would look something like this:
    LFSWriteClient *clientWrite = [LFSWriteClient
                                   clientWithNetwork:[LFSConfig objectForKey:@"domain"]
                                   environment:nil ];
    
    NSString *testString = [NSString stringWithFormat:@"Chars -):&@;));&(@ 1536495@ &$)((/ %zd",
                            arc4random()];
    
    [clientWrite postContentType:LFSPostTypeDefault
                   forCollection:[LFSConfig objectForKey:@"collection"]
                      parameters:
     @{LFSCollectionPostUserTokenKey:[LFSConfig objectForKey:@"moderator user auth token"],
       LFSCollectionPostBodyKey:testString}
                       onSuccess:^(NSOperation *operation, id responseObject) {
                           op = (AFHTTPRequestOperation*)operation;
                           result = responseObject;
                       }
                       onFailure:^(NSOperation *operation, NSError *error) {
                           op = (AFHTTPRequestOperation*)operation;
                           NSLog(@"Error code %zd, with recovery suggestion: %@",
                                 error.code, [error localizedRecoverySuggestion]);
                       }];

    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    if (op) {
        expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
        expect(op.error).notTo.equal(NSURLErrorTimedOut);
    }
    if (op.error != nil) {
        XCTFail(@"%@: %@", [op.error localizedDescription], [op.error localizedRecoverySuggestion]);
    }
    expect(result).will.beTruthy();
    
    if (result) {
        // check that response body matches the comment we posted
        expect(result).to.beKindOf([NSDictionary class]);
        NSDictionary *message = [[result objectForKey:@"messages"] objectAtIndex:0u];
        NSString *responseString = [[message objectForKey:@"content"] objectForKey:@"bodyHtml"];
        NSString *expectedString = [NSString stringWithFormat:@"<p>%@</p>", testString];
        expect(responseString).to.equal(expectedString);
    }
    
    NSString *contentId = [[result valueForKeyPath:@"messages.content.id"] objectAtIndex:0u];
    
    op = nil;
    result = nil;
    [clientWrite postMessage:LFSMessageDelete
                  forContent:contentId
                inCollection:[LFSConfig objectForKey:@"collection"]
                   userToken:[LFSConfig objectForKey:@"moderator user auth token"]
                  parameters:nil
                   onSuccess:^(NSOperation *operation, id responseObject) {
                       op = (AFHTTPRequestOperation*)operation;
                       result = responseObject;
                   }
                   onFailure:^(NSOperation *operation, NSError *error) {
                       op = (AFHTTPRequestOperation*)operation;
                       NSLog(@"Error code %zd, with recovery suggestion: %@",
                             error.code, [error localizedRecoverySuggestion]);
                   }];

    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    if (op) {
        expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
        expect(op.error).notTo.equal(NSURLErrorTimedOut);
    }
    if (op.error != nil) {
        XCTFail(@"%@: %@", [op.error localizedDescription], [op.error localizedRecoverySuggestion]);
    }
    expect(result).will.beTruthy();
    if (result) {
        expect(result).to.beKindOf([NSDictionary class]);
        NSString *idOfDeletedComment = [result objectForKey:@"comment_id"];
        expect(idOfDeletedComment).to.equal(contentId);
    }
}

- (void)testPostReview
{
    // Requires HTTP request encoding
    
    //Note: this test fails when the URL is wrong (the way it's meant to be)
    __block AFHTTPRequestOperation *op = nil;
    __block id result = nil;
    
    // Actual call would look something like this:
    LFSWriteClient *clientWrite = [LFSWriteClient
                                   clientWithNetwork:[LFSConfig objectForKey:@"domain"]
                                   environment:nil ];
    NSString *testString = [NSString stringWithFormat:@"The Horse and Pony is a great restaurant that would never replace your beef with horse meat %zd",
                            arc4random()];
    
    [clientWrite postContentType:LFSPostTypeReview
                   forCollection:[LFSConfig objectForKey:@"liveReviewCollection"]
                      parameters:
     @{LFSCollectionPostUserTokenKey:[LFSConfig objectForKey:@"liveReviewTestOwnerToken"],
       LFSCollectionPostBodyKey:testString,
       LFSCollectionPostTitleKey:@"The Horse and Pony",
       LFSCollectionPostRatingKey:@{@"default":@80}}
                       onSuccess:^(NSOperation *operation, id responseObject) {
                           op = (AFHTTPRequestOperation*)operation;
                           result = responseObject;
                       }
                       onFailure:^(NSOperation *operation, NSError *error) {
                           op = (AFHTTPRequestOperation*)operation;
                           NSLog(@"Error code %zd, with recovery suggestion: %@",
                                 error.code, [error localizedRecoverySuggestion]);
                       }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    if (op) {
        expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
        expect(op.error.code).to.equal(403); // only one review can be posted per user to a given collection
    }
    
    //expect(op.error).notTo.equal(NSURLErrorTimedOut);
    //expect(result).will.beTruthy();
    
    //NSDictionary *message = [[result objectForKey:@"messages"] objectAtIndex:0u];
    //NSString *responseString = [[message objectForKey:@"content"] objectForKey:@"bodyHtml"];
    //NSString *expectedString = [NSString stringWithFormat:@"<p>%@</p>", testString];
    //expect(responseString).to.equal(expectedString);

}

- (void)testPostInReplyTo
{
    
    // Requires HTTP request encoding
    
    //Note: this test fails when the URL is wrong (the way it's meant to be)
    __block AFHTTPRequestOperation *op = nil;
    __block id result = nil;
    
    NSString *parent = [LFSConfig objectForKey:@"content"];
    
    // Actual call would look something like this:
    LFSWriteClient *clientWrite = [LFSWriteClient
                                   clientWithNetwork:[LFSConfig objectForKey:@"domain"]
                                   environment:nil ];
    
    [clientWrite postContentType:LFSPostTypeDefault
                   forCollection:[LFSConfig objectForKey:@"collection"]
                      parameters:
     @{LFSCollectionPostUserTokenKey:[LFSConfig objectForKey:@"moderator user auth token"],
       LFSCollectionPostBodyKey:[NSString stringWithFormat:@"test reply, %zd", arc4random()],
       LFSCollectionPostParentIdKey:parent}
                       onSuccess:^(NSOperation *operation, id responseObject) {
                           op = (AFHTTPRequestOperation*)operation;
                           result = responseObject;
                       }
                       onFailure:^(NSOperation *operation, NSError *error) {
                           op = (AFHTTPRequestOperation*)operation;
                           NSLog(@"Error code %zd, with recovery suggestion: %@",
                                 error.code, [error localizedRecoverySuggestion]);
                       }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    if (op) {
        expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
        expect(op.error).notTo.equal(NSURLErrorTimedOut);
    }
    if (op.error != nil) {
        XCTFail(@"%@: %@", [op.error localizedDescription], [op.error localizedRecoverySuggestion]);
    }
    expect(result).will.beTruthy();
    if (result) {
        expect(result).to.beKindOf([NSDictionary class]);
        NSString *parent1 = [[[result objectForKey:@"messages"] objectAtIndex:0]
                             valueForKeyPath:@"content.parentId"];
        expect(parent1).to.equal(parent);
    }
}

#pragma mark - test flagging
- (void)testFlag
{

    // Requires HTTP request encoding
    
    //Note: this test fails when the URL is wrong (the way it's meant to be)
    __block AFHTTPRequestOperation *op = nil;
    __block id result = nil;
    
    // Actual call would look something like this:
    LFSWriteClient *clientWrite = [LFSWriteClient
                                   clientWithNetwork:[LFSConfig objectForKey:@"domain"]
                                   environment:nil ];
    [clientWrite postFlag:LFSFlagOfftopic
               forContent:[LFSConfig objectForKey:@"content"]
             inCollection:[LFSConfig objectForKey:@"collection"]
                userToken:[LFSConfig objectForKey:@"moderator user auth token"]
               parameters:@{@"notes":@"fakeNotes", @"email":@"fakeEmail"}
                onSuccess:^(NSOperation *operation, id responseObject) {
                    op = (AFHTTPRequestOperation*)operation;
                    result = responseObject;
                }
                onFailure:^(NSOperation *operation, NSError *error) {
                    op = (AFHTTPRequestOperation*)operation;
                    NSLog(@"Error code %zd, with recovery suggestion: %@",
                          error.code, [error localizedRecoverySuggestion]);
                }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    if (op) {
        expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
        expect(op.error).notTo.equal(NSURLErrorTimedOut);
    }
    if (op.error != nil) {
        XCTFail(@"%@: %@", [op.error localizedDescription], [op.error localizedRecoverySuggestion]);
    }
    expect(result).will.beTruthy();
}

#pragma mark - test collection creation
- (void)testCreateCollectionWithSecret
{
    //Note: this test fails when the URL is wrong (the way it's meant to be)
    __block AFHTTPRequestOperation *op = nil;
    __block id result = nil;
    
    // Modify article Id to a unique one to avoid error 409
    LFSWriteClient *clientWrite = [LFSWriteClient
                                   clientWithNetwork:[LFSConfig objectForKey:@"domain"]
                                   environment:nil ];
    
    [clientWrite postArticleForSite:[LFSConfig objectForKey:@"site"]
                        withSiteKey:[LFSConfig objectForKey:@"site key"]
                     collectionMeta:@{LFSCollectionMetaArticleIdKey:@"justTesting12",
                                      LFSCollectionMetaURLKey:@"http://erere.com/ererereer",
                                      LFSCollectionMetaTitleKey:@"La la la la",
                                      LFSCollectionMetaTagsKey:@[@"hey", @"hello"]}
                          onSuccess:^(NSOperation *operation, id responseObject) {
                              op = (AFHTTPRequestOperation*)operation;
                              result = responseObject;
                          }
                          onFailure:^(NSOperation *operation, NSError *error) {
                              op = (AFHTTPRequestOperation*)operation;
                              NSLog(@"Error code %zd, with recovery suggestion: %@",
                                    error.code, [error localizedRecoverySuggestion]);
                          }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    if (op) {
        expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
        expect(op.error).notTo.equal(NSURLErrorTimedOut);
        if (op.error) {
            // HTTP 409:
            // Collection already exists for site_id ... and article_id ... Use update instead
            expect(op.response.statusCode).to.equal(409);
        } else {
            // HTTP 202:
            // This request is being processed
            expect(op.response.statusCode).to.equal(202);
        }
    }
}

- (void)testCreateCollectionUnsigned
{
    //Note: this test fails when the URL is wrong (the way it's meant to be)
    __block AFHTTPRequestOperation *op = nil;
    __block id result = nil;
    
    // Modify article Id to a unique one to avoid error 409
    LFSWriteClient *clientWrite = [LFSWriteClient
                                   clientWithNetwork:[LFSConfig objectForKey:@"domain"]
                                   environment:nil ];
    
    [clientWrite postArticleForSite:[LFSConfig objectForKey:@"site"]
                        withSiteKey:nil
                     collectionMeta:@{LFSCollectionMetaArticleIdKey:@"justTesting11",
                                      LFSCollectionMetaURLKey:@"http://erere.com/ererereer"}
                          onSuccess:^(NSOperation *operation, id responseObject) {
                              op = (AFHTTPRequestOperation*)operation;
                              result = responseObject;
                          }
                          onFailure:^(NSOperation *operation, NSError *error) {
                              op = (AFHTTPRequestOperation*)operation;
                              NSLog(@"Error code %zd, with recovery suggestion: %@",
                                    error.code, [error localizedRecoverySuggestion]);
                          }];

    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    if (op) {
        expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
        expect(op.error).notTo.equal(NSURLErrorTimedOut);
        if (op.error) {
            // HTTP 409: Collection already exists for site_id ... and article_id .... Use update instead.
            expect(op.response.statusCode).to.equal(409);
        } else {
            // HTTP 202: This request is being processed.
            expect(op.response.statusCode).to.equal(202);
        }
    }
}

#pragma mark - Test Streaming API

- (void)testStreamAndPost {
    // Get Init
    __block AFHTTPRequestOperation *op0 = nil;
    
    // This is the easiest way to use LFHTTPClient
    __block NSDictionary *bootstrapInitInfo = nil;
    LFSBootstrapClient *clientStreamBootstrap = [LFSBootstrapClient clientWithNetwork:[LFSConfig objectForKey:@"writableNetwork"]
                                                                          environment:[LFSConfig objectForKey:@"writableEnvironment"]];
    [clientStreamBootstrap getInitForSite:[LFSConfig objectForKey:@"writableSiteId"]
                                  article:[LFSConfig objectForKey:@"writableArticleId"]
                                onSuccess:^(NSOperation *operation, id JSON){
                                    op0 = (AFHTTPRequestOperation*)operation;
                                    bootstrapInitInfo = JSON;
                                }
                                onFailure:^(NSOperation *operation, NSError *error) {
                                    op0 = (AFHTTPRequestOperation*)operation;
                                    NSLog(@"Error code %zd, with recovery suggestion: %@",
                                          error.code, [error localizedRecoverySuggestion]);
                                }
     ];
    
    // Wait 'til done and then verify that everything is OK
    expect(op0.isFinished).will.beTruthy();
    expect(op0).to.beInstanceOf([AFHTTPRequestOperation class]);
    expect(op0.error).notTo.equal(NSURLErrorTimedOut);
    
    expect(bootstrapInitInfo).will.beTruthy();
    if (bootstrapInitInfo) {
        expect(bootstrapInitInfo).to.beKindOf([NSDictionary class]);
        expect([bootstrapInitInfo allKeys]).to.beSupersetOf(@[@"networkSettings", @"headDocument", @"collectionSettings", @"siteSettings"]);
    }
    
    NSDictionary *collectionSettings = [bootstrapInitInfo objectForKey:@"collectionSettings"];
    NSString *collectionId = [collectionSettings objectForKey:@"collectionId"];
    NSNumber *eventId = [collectionSettings objectForKey:@"event"];
    
    __block id resultStream = nil;
    
    // generate the string that will be posted to this collection post early on
    NSString *testString = [NSString stringWithFormat:@"testing streaming API %zd",
                            arc4random()];
    
    LFSStreamClient *clientStream = [LFSStreamClient clientWithNetwork:[LFSConfig objectForKey:@"writableNetwork"]
                                                           environment:[LFSConfig objectForKey:@"writableEnvironment"]];
    
    [clientStream setCollectionId:collectionId];
    [clientStream setResultHandler:^(id responseObject) {
        // cycle through response objects until we find one that contains the string posted
        NSString *bodyHtml = [[responseObject objectForKey:@"content"] objectForKey:@"bodyHtml"];
        if ([bodyHtml rangeOfString:testString].location != NSNotFound) {
            resultStream = responseObject;
            NSLog(@"Obtained stream object: %@", responseObject);
        }
    } success:nil failure:nil];
    [clientStream startStreamWithEventId:eventId];
    

    // now actually post the string we generated above
    __block AFHTTPRequestOperation *op = nil;
    __block id resultPost = nil;
    
    LFSWriteClient *clientWrite = [LFSWriteClient
                                   clientWithNetwork:[LFSConfig objectForKey:@"writableNetwork"]
                                   environment:[LFSConfig objectForKey:@"writableEnvironment"]];
    
    [clientWrite postContentType:LFSPostTypeDefault
                   forCollection:collectionId
                      parameters:
     @{LFSCollectionPostUserTokenKey:[LFSConfig objectForKey:@"writableLftoken"],
       LFSCollectionPostBodyKey:testString}
                       onSuccess:^(NSOperation *operation, id responseObject) {
                           op = (AFHTTPRequestOperation*)operation;
                           resultPost = responseObject;
                           NSLog(@"Obtained POST response object: %@", resultPost);
                       }
                       onFailure:^(NSOperation *operation, NSError *error) {
                           op = (AFHTTPRequestOperation*)operation;
                           NSLog(@"Error code %zd, with recovery suggestion: %@",
                                 error.code, [error localizedRecoverySuggestion]);
                       }];
    
    expect(resultPost).will.beTruthy();
    expect(resultStream).will.beTruthy();
}


@end
