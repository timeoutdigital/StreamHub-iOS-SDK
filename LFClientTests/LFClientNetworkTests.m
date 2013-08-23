//
//  LFClientTests.m
//  LFClientTests
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


#import <SenTestingKit/SenTestingKit.h>

#import "LFClient.h"
#import "LFConfig.h"
#import "LFHTTPBoostrapClient.h"
#import "LFJSONRequestOperation.h"
#import "NSString+Base64Encoding.h"
#import <AFJSONRequestOperation.h>

#define EXP_SHORTHAND YES
#import "Expecta.h"

@interface LFClientNetworkTests : SenTestCase
@end

@interface LFClientNetworkTests()
@property (nonatomic) NSString *event;
@property (readwrite, nonatomic, strong) LFHTTPBoostrapClient *client;
@end

@implementation LFClientNetworkTests

- (void)setUp
{
    [super setUp];

    // Set-up code here.
    if (![LFConfig objectForKey:@"domain"]) {
        STFail(@"No test settings");
    }
    
    self.client = [LFHTTPBoostrapClient clientWithEnvironment:[LFConfig objectForKey:@"environment"] network:[LFConfig objectForKey:@"domain"]];
    
    // set timeout to 60 seconds
    [Expecta setAsynchronousTestTimeout:60.0f];
}

- (void)tearDown
{
    // Tear-down code here.
    
    // cancelling all operations just in case (not strictly required)
    for (NSOperation *operation in self.client.operationQueue.operations) {
        [operation cancel];
    }
    self.client = nil;
    
    [super tearDown];
}

#pragma mark - Get init
- (void)testCollectionRetrieval {
    __block NSDictionary *coll = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    [LFBootstrapClient getInitForArticle:[LFConfig objectForKey:@"article"]
                                    site:[LFConfig objectForKey:@"site"]
                                 network:[LFConfig objectForKey:@"domain"]
                             environment:[LFConfig objectForKey:@"environment"]
                               onSuccess:^(NSDictionary *collection) {
                                   coll = collection;
                                   dispatch_semaphore_signal(sema);
                               }
                               onFailure:^(NSError *error) {
                                   NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                                   dispatch_semaphore_signal(sema);
                               }];
    
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    
    //Need status code from backend
    self.event = [[coll objectForKey:@"collectionSettings"] objectForKey:@"event"];
    STAssertNotNil(self.event, @"Should have fetched a head document");
}

- (void)testInitWithLFJSONRequestOperation
{
    __block id result = nil;
    
    // Most complicated way to use LFHTTPClient... Nevertheless it should work
    NSString* path = [NSString stringWithFormat:@"/bs3/%@/%@/%@/init",
                      [LFConfig objectForKey:@"domain"],
                      [LFConfig objectForKey:@"site"],
                      [[LFConfig objectForKey:@"article"] base64EncodedString]];
    NSURLRequest *request = [self.client requestWithMethod:@"GET" path:path parameters:nil];
    LFJSONRequestOperation *op = [LFJSONRequestOperation
                                  JSONRequestOperationWithRequest:request
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                      result = JSON;
                                  }
                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                      NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                                  }];
    [self.client enqueueHTTPRequestOperation:op];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    expect(op.error).notTo.equal(NSURLErrorTimedOut);
    expect(op.response.statusCode).to.equal(200);
    // Collection dictionary should have 4 keys: headDocument, collectionSettings, networkSettings, siteSettings
    expect(result).to.haveCountOf(4);
}

- (void)testInitWithGetPath
{
    __block AFHTTPRequestOperation *op = nil;
    __block id result = nil;
    
    // Second easiest way to use LFHTTPClient
    NSString* path = [NSString stringWithFormat:@"/bs3/%@/%@/%@/init",
                      [LFConfig objectForKey:@"domain"],
                      [LFConfig objectForKey:@"site"],
                      [[LFConfig objectForKey:@"article"] base64EncodedString]];
    [self.client getPath:path
              parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id JSON){
                     op = operation;
                     result = JSON;
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     op = operation;
                     NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                 }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    expect(op).to.beInstanceOf([LFJSONRequestOperation class]);
    expect(op.error).notTo.equal(NSURLErrorTimedOut);
    // Collection dictionary should have 4 keys: headDocument, collectionSettings, networkSettings, siteSettings
    expect(result).to.haveCountOf(4);
}

- (void)testInitWithGetInitForArticle
{
    __block LFJSONRequestOperation *op = nil;
    __block id result = nil;
    
    // This is the easiest way to use LFHTTPClient
    [self.client getInitForSite:[LFConfig objectForKey:@"site"]
                        article:[LFConfig objectForKey:@"article"]
                      onSuccess:^(NSOperation *operation, id JSON){
                          op = (LFJSONRequestOperation*)operation;
                          result = JSON;
                      }
                      onFailure:^(NSOperation *operation, NSError *error) {
                          op = (LFJSONRequestOperation*)operation;
                          NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                      }
     ];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    expect(op).to.beInstanceOf([LFJSONRequestOperation class]);
    expect(op.error).notTo.equal(NSURLErrorTimedOut);
    // Collection dictionary should have 4 keys: headDocument, collectionSettings, networkSettings, siteSettings
    expect(result).to.haveCountOf(4);
}

#pragma mark - Retrieve Hottest Collections
- (void)testHeatAPIResultRetrieval
{
    __block NSArray *res = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

    [LFBootstrapClient getHottestCollectionsForTag:@"tag"
                                             site:[LFConfig objectForKey:@"site"]
                                          network:[LFConfig objectForKey:@"domain"]
                                     desiredResults:10u
                                            onSuccess:^(NSArray *results) {
                                                res = results;
                                                dispatch_semaphore_signal(sema);
                                            } onFailure:^(NSError *error) {
                                                NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                                                dispatch_semaphore_signal(sema);
                                            }];
 
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    
    STAssertNotNil(res, @"Should have returned results");
}

- (void)testHeatAPIWithGetHottestCollections
{
    __block LFJSONRequestOperation *op = nil;
    __block NSArray *result = nil;
    
    // Actual call would look something like this:
    [self.client getHottestCollectionsForSite:[LFConfig objectForKey:@"site"]
                                          tag:@"tag"
                               desiredResults:10u
                                    onSuccess:^(NSOperation *operation, id responseObject) {
                                        op = (LFJSONRequestOperation *)operation;
                                        result = (NSArray *)responseObject;
                                    } onFailure:^(NSOperation *operation, NSError *error) {
                                        op = (LFJSONRequestOperation *)operation;
                                        NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                                    }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    expect(op).to.beInstanceOf([LFJSONRequestOperation class]);
    expect(op.error).notTo.equal(NSURLErrorTimedOut);
    expect(result).to.beTruthy();
}

#pragma mark - Retrieve User Data
- (void)testUserDataRetrieval {
    __block NSArray *res = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [LFBootstrapClient getUserContentForUser:[LFConfig objectForKey:@"system user"]
                                   withToken:nil
                                   forNetwork:[LFConfig objectForKey:@"labs network"]
                                 statuses:nil
                                  offset:nil
                                     onSuccess:^(NSArray *results) {
                                         res = results;
                                         dispatch_semaphore_signal(sema);
                                   } onFailure:^(NSError *error) {
                                        NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                                        dispatch_semaphore_signal(sema);
                                   }];
    
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));

    STAssertNotNil(res, @"Should have returned results");
}

#pragma mark - Test user authentication
- (void)testUserAuthenticationSiteArticle {
    //with article and site ids
    __block NSDictionary *res = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSString *userToken = [LFConfig objectForKey:@"moderator user auth token"];
    
    [LFAdminClient authenticateUserWithToken:userToken
                                  article:[LFConfig objectForKey:@"article"]
                                     site:[LFConfig objectForKey:@"site"]
                                   network:[LFConfig objectForKey:@"domain"]
                                     onSuccess:^(NSDictionary *gotUserData) {
                                         res = gotUserData;
                                         dispatch_semaphore_signal(sema);
                                     } onFailure:^(NSError *error) {
                                         NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                                         dispatch_semaphore_signal(sema);
                                     }];
    
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    
    STAssertEqualObjects([res objectForKey:@"status"], @"ok", @"This response should have been ok");
}

- (void)testUserAuthenticationCollection {
    //with collection id
    __block NSDictionary *res = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSString *userToken = [LFConfig objectForKey:@"moderator user auth token"];
    
    [LFAdminClient authenticateUserWithToken:userToken
                                  collection:[LFConfig objectForKey:@"collection"]
                                     network:[LFConfig objectForKey:@"domain"]
                                   onSuccess:^(NSDictionary *gotUserData) {
                                       res = gotUserData;
                                       dispatch_semaphore_signal(sema);
                                   } onFailure:^(NSError *error) {
                                       NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                                       dispatch_semaphore_signal(sema);
                                   }];
    
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    
    STAssertEqualObjects([res objectForKey:@"status"], @"ok", @"This response should have been ok");
}

- (void)testLikes {
    __block NSDictionary *res = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSString *userToken = [LFConfig objectForKey:@"moderator user auth token"];

    [LFWriteClient likeContent:[LFConfig objectForKey:@"content"]
                       forUser:userToken
                  collection:[LFConfig objectForKey:@"collection"]
                     network:[LFConfig objectForKey:@"domain"]
                       onSuccess:^(NSDictionary *content) {
                           res = content;
                           dispatch_semaphore_signal(sema);
                       } onFailure:^(NSError *error) {
                           NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                           dispatch_semaphore_signal(sema);
                       }];
    
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    
    STAssertEqualObjects([res objectForKey:@"status"], @"ok", @"This response should have been ok");
    
    res = nil;
    [LFWriteClient unlikeContent:[LFConfig objectForKey:@"content"]
                       forUser:userToken
                  collection:[LFConfig objectForKey:@"collection"]
                     network:[LFConfig objectForKey:@"domain"]
                       onSuccess:^(NSDictionary *content) {
                           res = content;
                           dispatch_semaphore_signal(sema);
                       } onFailure:^(NSError *error) {
                           NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                           dispatch_semaphore_signal(sema);
                       }];
    
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    
    STAssertEqualObjects([res objectForKey:@"status"], @"ok", @"This response should have been ok");
}

- (void)testPost {
    __block NSDictionary *res = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSString *userToken = [LFConfig objectForKey:@"moderator user auth token"];
    NSUInteger ran = arc4random();
    
    NSString *content = [NSString stringWithFormat:@"test post, %d", ran];
    NSLog(@"Posting content: %@", content);
    [LFWriteClient postContent:content
                       forUser:userToken
                     inReplyTo:nil
                  forCollection:[LFConfig objectForKey:@"collection"]
                     network:[LFConfig objectForKey:@"domain"]
                       onSuccess:^(NSDictionary *content) {
                           res = content;
                           dispatch_semaphore_signal(sema);
                       } onFailure:^(NSError *error) {
                           NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                           dispatch_semaphore_signal(sema);
                       }];
    
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    
    STAssertEqualObjects([res objectForKey:@"status"], @"ok", @"This response should have been ok");
}

- (void)testPostReplyTo {
    //in reply to
    __block NSDictionary *res = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSString *parent = [LFConfig objectForKey:@"content"];
    NSString *userToken = [LFConfig objectForKey:@"moderator user auth token"];
    NSUInteger ran = ran = arc4random();
    [LFWriteClient postContent:[NSString stringWithFormat:@"test reply, %d", ran]
                       forUser:userToken
                     inReplyTo:parent
                  forCollection:[LFConfig objectForKey:@"collection"]
                     network:[LFConfig objectForKey:@"domain"]
                       onSuccess:^(NSDictionary *content) {
                           res = content;
                           dispatch_semaphore_signal(sema);
                       } onFailure:^(NSError *error) {
                           NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                           dispatch_semaphore_signal(sema);
                       }];
    
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));

    NSString *prent = [[[[[res objectForKey:@"data"] objectForKey:@"messages"] objectAtIndex:0] objectForKey:@"content"] objectForKey:@"parentId"];
    STAssertEqualObjects(prent, parent, @"This response should have been a child.");
}

    //share to
//    ran = arc4random();
//    [LFWriteClient postContent:[NSString stringWithFormat:@"test reply, %d", ran]
//                       forUser:userToken
//                     inReplyTo:nil
//                       shareTo:@[kShareTypeTwitter]
//                  inCollection:@"10665123"
//                     onNetwork:[Config objectForKey:@"domain"]
//                       success:^(NSDictionary *content) {
//                           res = content;
//                           dispatch_semaphore_signal(sema);
//                       } failure:^(NSError *error) {
//                           NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
//                           dispatch_semaphore_signal(sema);
//                       }];
//    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
//    STAssertEqualObjects(prent, parent, @"This response should have been a child.");
//    NSLog(@"Successfully posted w/ shareTo");

//- (void)testStream {
//    __block NSDictionary *res = nil;
//    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
//    
//    LFStreamClient *streamer = [LFStreamClient new];
//    [streamer startStreamForCollection:[Config objectForKey:@"collection"]
//                             fromEvent:@"2648462675" //the past
//                             onNetwork:[Config objectForKey:@"domain"]
//                               success:^(NSDictionary *updates) {
//                                   res = updates;
//                                   dispatch_semaphore_signal(sema);
//                               } failure:^(NSError *error) {
//                                   NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
//                                   dispatch_semaphore_signal(sema);
//                               }];
//    
//    dispatch_semaphore_wait(sema, 10 * NSEC_PER_SEC);
//    NSLog(@"Successfully streamed");
//    
//    [streamer stopStreamForCollection:[Config objectForKey:@"collection"]];
//}

- (void)testFlag {
    __block NSDictionary *res = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

    [LFWriteClient flagContent:[LFConfig objectForKey:@"content"]
                 forCollection:[LFConfig objectForKey:@"collection"]
                       network:[LFConfig objectForKey:@"domain"]
                      withFlag:LFFlagOfftopic
                          user:[LFConfig objectForKey:@"moderator user auth token"]
                         notes:@"fakeNotes"
                         email:@"fakeEmail"
                     onSuccess:^(NSDictionary *opineData) {
                         res = opineData;
                         dispatch_semaphore_signal(sema);
                     } onFailure:^(NSError *error) {
                         NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                         dispatch_semaphore_signal(sema);
                     }];

    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));

    STAssertEqualObjects([res objectForKey:@"status"], @"ok", @"This response should have been ok");
}

@end
