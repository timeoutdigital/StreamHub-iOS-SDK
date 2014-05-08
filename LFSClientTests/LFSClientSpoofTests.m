//
//  LFSClientSpoofTests.m
//  LFSClient
//
//  Created by zjj on 1/23/13.
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
#import <AFHTTPRequestOperationLogger/AFHTTPRequestOperationLogger.h>

#import "LFSClient.h"
#import "LFSConfig.h"
#import "LFSBootstrapClient.h"
#import "LFSAdminClient.h"
#import "LFSWriteClient.h"

#define EXP_SHORTHAND YES
#import <Expecta/Expecta.h>

#import <OHHTTPStubs/OHHTTPStubs.h>


@interface LFSClientSpoofTests : XCTestCase
@end

@implementation LFSClientSpoofTests
- (void)setUp
{
    [super setUp];
    
    // set timeout to 60 seconds
    [Expecta setAsynchronousTestTimeout:60.0f];
    [[AFHTTPRequestOperationLogger sharedLogger] startLogging];
}

- (void)tearDown
{
    [[AFHTTPRequestOperationLogger sharedLogger] stopLogging];
    [super tearDown];
}

#pragma mark - Test Bootstrap Client

- (void)testLFHTTPClient
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        NSURL *requestURL = request.URL;
        return [requestURL.host isEqualToString:@"bootstrap.init-sample"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        // Stub it with our own file
        NSString *filePath = OHPathForFileInBundle(@"init-sample.json", nil);
        NSDictionary *headers = @{@"Content-Type": @"application/x-javascript"};
        return [OHHTTPStubsResponse responseWithFileAtPath:filePath
                                                statusCode:200
                                                   headers:headers];
    }];
    
    // Get Init
    __block AFHTTPRequestOperation *op0 = nil;
    
    // This is the easiest way to use LFHTTPClient
    __block NSDictionary *bootstrapInitInfo = nil;
    
    LFSBootstrapClient *client = [LFSBootstrapClient clientWithNetwork:@"init-sample"
                                                           environment:nil ];
    [client getInitForSite:@"fakeSite"
                   article:@"fakeArticle"
                 onSuccess:^(NSOperation *operation, id JSON){
                     op0 = (AFHTTPRequestOperation*)operation;
                     bootstrapInitInfo = JSON;
                 }
                 onFailure:^(NSOperation *operation, NSError *error) {
                     op0 = (AFHTTPRequestOperation*)operation;
                     NSLog(@"Error code %zd, with description %@",
                           error.code,
                           [error localizedDescription]);
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
    
    // Get Page 1
    // (note that returned operation can be an instance of NSBlockOperation)
    __block NSDictionary *contentInfo1 = nil;
    __block id op1 = nil;
    [client getContentForPage:0
                    onSuccess:^(id operation, id JSON){
                        op1 = operation;
                        contentInfo1 = JSON;
                    }
                    onFailure:^(id operation, NSError *error) {
                        op1 = operation;
                        NSLog(@"Error code %zd, with description %@",
                              error.code,
                              [error localizedDescription]);
                    }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op1).will.beTruthy();
    expect([op1 isFinished]).will.beTruthy();
    expect(contentInfo1).to.beTruthy();
    
    // Get Page 2
    __block NSDictionary *contentInfo2 = nil;
    __block AFHTTPRequestOperation *op2 = nil;
    [client getContentForPage:1
                    onSuccess:^(NSOperation *operation, id JSON){
                        op2 = (AFHTTPRequestOperation*)operation;
                        contentInfo2 = JSON;
                    }
                    onFailure:^(NSOperation *operation, NSError *error) {
                        op2 = (AFHTTPRequestOperation*)operation;
                        NSLog(@"Error code %zd, with description %@",
                              error.code,
                              [error localizedDescription]);
                    }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op2).will.beTruthy();
    expect(op2.isFinished).will.beTruthy();
    expect(op2).to.beInstanceOf([AFHTTPRequestOperation class]);
    expect(op2.error).notTo.equal(NSURLErrorTimedOut);
    expect(contentInfo2).to.beTruthy();
}

- (void)testFeatured
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        NSURL *requestURL = request.URL;
        return [requestURL.host isEqualToString:@"bootstrap.featured-sample"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        // Stub it with our own file
        NSString *filePath = OHPathForFileInBundle(@"featured-sample.json", nil);
        NSDictionary *headers = @{@"Content-Type": @"application/x-javascript"};
        return [OHHTTPStubsResponse responseWithFileAtPath:filePath
                                                statusCode:200
                                                   headers:headers];
    }];
    
    __block AFHTTPRequestOperation *op = nil;
    __block id result = nil;
    
    // Actual call would look something like this:
    LFSBootstrapClient *client = [LFSBootstrapClient clientWithNetwork:@"featured-sample"
                                                           environment:nil ];
    [client getFeaturedForSite:@"fakeSite"
                   article:@"fakeArticle"
                          head:YES
                 onSuccess:^(NSOperation *operation, id JSON){
                     op = (AFHTTPRequestOperation*)operation;
                     result = JSON;
                 }
                 onFailure:^(NSOperation *operation, NSError *error) {
                     op = (AFHTTPRequestOperation*)operation;
                     NSLog(@"Error code %zd, with description %@",
                           error.code,
                           [error localizedDescription]);
                 }
     ];

    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
    expect(op.error).notTo.equal(NSURLErrorTimedOut);
    expect(result).will.beTruthy();
    if (result) {
        expect(result).to.beKindOf([NSDictionary class]);
        expect([result allKeys]).to.beSupersetOf(@[@"content", @"authors", @"size", @"isComplete"]);
    }
}

- (void)testHeatAPIWithGetHottestCollections
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        NSURL *requestURL = request.URL;
        return [requestURL.host isEqualToString:@"bootstrap.hottest-sample"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        // Stub it with our own file
        NSString *filePath = OHPathForFileInBundle(@"hottest-sample.json", nil);
        NSDictionary *headers = @{@"Content-Type": @"application/x-javascript"};
        return [OHHTTPStubsResponse responseWithFileAtPath:filePath
                                                statusCode:200
                                                   headers:headers];
    }];
    
    __block AFHTTPRequestOperation *op = nil;
    __block NSArray *result = nil;
    
    // Actual call would look something like this:
    LFSBootstrapClient *clientHottest = [LFSBootstrapClient
                                         clientWithNetwork:@"hottest-sample" environment:nil];
    [clientHottest getHottestCollectionsForSite:@"site"
                                            tag:@"taggy"
                                 desiredResults:10u
                                      onSuccess:^(NSOperation *operation, id responseObject) {
                                          op = (AFHTTPRequestOperation *)operation;
                                          result = (NSArray *)responseObject;
                                      } onFailure:^(NSOperation *operation, NSError *error) {
                                          op = (AFHTTPRequestOperation *)operation;
                                          NSLog(@"Error code %zd, with description %@",
                                                error.code,
                                                [error localizedDescription]);
                                      }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
    expect(op.error).notTo.equal(NSURLErrorTimedOut);
    expect(result).will.beTruthy();
    if (result) {
        expect(result).to.beKindOf([NSArray class]);
        expect(result).to.haveCountOf(10u);
    }
}

- (void)testUserDataWithGetContentForUser
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        NSURL *requestURL = request.URL;
        return [requestURL.host isEqualToString:@"bootstrap.usercontent-sample"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        // Stub it with our own file
        NSString *filePath = OHPathForFileInBundle(@"usercontent-sample.json", nil);
        NSDictionary *headers = @{@"Content-Type": @"application/x-javascript"};
        return [OHHTTPStubsResponse responseWithFileAtPath:filePath
                                                statusCode:200
                                                   headers:headers];
    }];
    
    __block AFHTTPRequestOperation *op = nil;
    __block NSArray *result = nil;
    
    // Actual call would look something like this:
    LFSBootstrapClient *client = [LFSBootstrapClient clientWithNetwork:@"usercontent-sample" environment:nil];
    [client getUserContentForUser:@"fakeUser"
                            token:nil
                         statuses:nil
                           offset:nil
                        onSuccess:^(NSOperation *operation, id responseObject) {
                            op = (AFHTTPRequestOperation *)operation;
                            result = (NSArray *)responseObject;
                        } onFailure:^(NSOperation *operation, NSError *error) {
                            op = (AFHTTPRequestOperation *)operation;
                            NSLog(@"Error code %zd, with description %@",
                                  error.code,
                                  [error localizedDescription]);
                        }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
    expect(op.error).notTo.equal(NSURLErrorTimedOut);
    expect(result).will.beTruthy();
    if (result) {
        expect(result).to.beKindOf([NSArray class]);
        expect(result).to.haveCountOf(12u);
    }
}

#pragma mark - Test Admin Client
- (void)testUserAuthenticationCollection
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        NSURL *requestURL = request.URL;
        return [requestURL.host isEqualToString:@"admin.usercontent-sample"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        // Stub it with our own file
        NSString *filePath = OHPathForFileInBundle(@"usercontent-sample.json", nil);
        NSDictionary *headers = @{@"Content-Type": @"application/x-javascript"};
        return [OHHTTPStubsResponse responseWithFileAtPath:filePath
                                                statusCode:200
                                                   headers:headers];
    }];
    
    __block AFHTTPRequestOperation *op = nil;
    __block id result = nil;
    
    // Actual call would look something like this:
    LFSAdminClient *clientAdmin = [LFSAdminClient clientWithNetwork:@"usercontent-sample" environment:nil];
    [clientAdmin authenticateUserWithToken:@"fakeToken"
                                collection:@"fakeColl"
                                 onSuccess:^(NSOperation *operation, id responseObject) {
                                     op = (AFHTTPRequestOperation *)operation;
                                     result = (NSArray *)responseObject;
                                 }
                                 onFailure:^(NSOperation *operation, NSError *error) {
                                     op = (AFHTTPRequestOperation *)operation;
                                     NSLog(@"Error code %zd, with description %@",
                                           error.code,
                                           [error localizedDescription]);
                                 }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
    expect(op.error).notTo.equal(NSURLErrorTimedOut);
    expect(result).will.beTruthy();
}

- (void)testUserAuthenticationSiteArticle
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        NSURL *requestURL = request.URL;
        return [requestURL.host isEqualToString:@"admin.usercontent-sample"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        // Stub it with our own file
        NSString *filePath = OHPathForFileInBundle(@"usercontent-sample.json", nil);
        NSDictionary *headers = @{@"Content-Type": @"application/x-javascript"};
        return [OHHTTPStubsResponse responseWithFileAtPath:filePath
                                                statusCode:200
                                                   headers:headers];
    }];
    
    __block AFHTTPRequestOperation *op = nil;
    __block id result = nil;
    
    // Actual call would look something like this:
    LFSAdminClient *clientAdmin = [LFSAdminClient clientWithNetwork:@"usercontent-sample" environment:nil];
    [clientAdmin authenticateUserWithToken:@"fakeToken"
                                      site:@"fakeSite"
                                   article:@"fakeArticle"
                                 onSuccess:^(NSOperation *operation, id responseObject) {
                                     op = (AFHTTPRequestOperation *)operation;
                                     result = (NSArray *)responseObject;
                                 }
                                 onFailure:^(NSOperation *operation, NSError *error) {
                                     op = (AFHTTPRequestOperation *)operation;
                                     NSLog(@"Error code %zd, with description %@",
                                           error.code,
                                           [error localizedDescription]);
                                 }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
    expect(op.error).notTo.equal(NSURLErrorTimedOut);
    expect(result).will.beTruthy();
}

#pragma mark - Test Write Client
- (void)testLikes
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        NSURL *requestURL = request.URL;
        return [requestURL.host isEqualToString:@"quill.like-sample"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        // Stub it with our own file
        NSString *filePath = OHPathForFileInBundle(@"like-sample.json", nil);
        NSDictionary *headers = @{@"Content-Type": @"application/x-javascript"};
        return [OHHTTPStubsResponse responseWithFileAtPath:filePath
                                                statusCode:200
                                                   headers:headers];
    }];
    
    __block AFHTTPRequestOperation *op = nil;
    __block id result = nil;
    
    // Actual call would look something like this:
    LFSWriteClient *clientLike = [LFSWriteClient clientWithNetwork:@"like-sample" environment:nil ];
    [clientLike postMessage:LFSMessageLike
                 forContent:@"fakeContent"
               inCollection:@"fakeColl"
                  userToken:@"fakeUserToken"
                 parameters:nil
                  onSuccess:^(NSOperation *operation, id responseObject) {
                      op = (AFHTTPRequestOperation*)operation;
                      result = responseObject;
                  }
                  onFailure:^(NSOperation *operation, NSError *error) {
                      op = (AFHTTPRequestOperation*)operation;
                      NSLog(@"Error code %zd, with description %@",
                            error.code,
                            [error localizedDescription]);
                  }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
    expect(op.error).notTo.equal(NSURLErrorTimedOut);
    expect(result).will.beTruthy();
}

- (void)testPost
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        NSURL *requestURL = request.URL;
        return [requestURL.host isEqualToString:@"quill.post-sample"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        // Stub it with our own file
        NSString *filePath = OHPathForFileInBundle(@"post-sample.json", nil);
        NSDictionary *headers = @{@"Content-Type": @"application/x-javascript"};
        return [OHHTTPStubsResponse responseWithFileAtPath:filePath
                                                statusCode:200
                                                   headers:headers];
    }];
    
    __block AFHTTPRequestOperation *op = nil;
    __block id result = nil;
    
    // Actual call would look something like this:
    NSString *content = [NSString
                         stringWithFormat:@"test post freie_plätze, %zd",
                         arc4random()];
    
    LFSWriteClient *clientWrite = [LFSWriteClient clientWithNetwork:@"post-sample" environment:nil ];
    
    [clientWrite postContentType:LFSPostTypeDefault
                   forCollection:@"fakeColl"
                      parameters:
     @{LFSCollectionPostUserTokenKey:@"fakeUser",
       LFSCollectionPostBodyKey:content}
                       onSuccess:^(NSOperation *operation, id responseObject) {
                           op = (AFHTTPRequestOperation*)operation;
                           result = responseObject;
                       }
                       onFailure:^(NSOperation *operation, NSError *error) {
                           op = (AFHTTPRequestOperation*)operation;
                           NSLog(@"Error code %zd, with description %@",
                                 error.code,
                                 [error localizedDescription]);
                       }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
    expect(op.error).notTo.equal(NSURLErrorTimedOut);
    expect(result).will.beTruthy();
}

- (void)testFlag
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        NSURL *requestURL = request.URL;
        return [requestURL.host isEqualToString:@"quill.flag-sample"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        // Stub it with our own file
        NSString *filePath = OHPathForFileInBundle(@"flag-sample.json", nil);
        NSDictionary *headers = @{@"Content-Type": @"application/x-javascript"};
        return [OHHTTPStubsResponse responseWithFileAtPath:filePath
                                                statusCode:200
                                                   headers:headers];
    }];
    
    __block AFHTTPRequestOperation *op = nil;
    __block id result = nil;
    
    // Actual call would look something like this:
    LFSWriteClient *clientFlag = [LFSWriteClient clientWithNetwork:@"flag-sample" environment:nil ];
    [clientFlag postFlag:LFSFlagOfftopic
              forContent:@"fakeContent"
            inCollection:@"fakeCollection"
               userToken:@"fakeUserToken"
              parameters:@{@"notes":@"fakeNotes", @"email":@"fakeEmail"}
               onSuccess:^(NSOperation *operation, id responseObject) {
                   op = (AFHTTPRequestOperation*)operation;
                   result = responseObject;
               }
               onFailure:^(NSOperation *operation, NSError *error) {
                   op = (AFHTTPRequestOperation*)operation;
                   NSLog(@"Error code %zd, with description %@",
                         error.code,
                         [error localizedDescription]);
               }];
    
    // Wait til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    if (op) {
        expect(op).to.beInstanceOf([AFHTTPRequestOperation class]);
        expect(op.error).notTo.equal(NSURLErrorTimedOut);
        expect(op.response.statusCode).to.equal(200);
    }

    expect(result).will.beTruthy();
    if (result) {
        expect(result).to.beKindOf([NSDictionary class]);
        expect([result allKeys]).to.beSupersetOf(@[@"messageId", @"opinionId"]);
    }
}

@end
