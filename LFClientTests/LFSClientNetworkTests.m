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
#import "LFSConfig.h"
#import "LFSBoostrapClient.h"
#import "LFSAdminClient.h"
#import "LFSWriteClient.h"

#import "LFSJSONRequestOperation.h"
#import "MF_Base64Additions.h"

#import <AFJSONRequestOperation.h>

#define EXP_SHORTHAND YES
#import "Expecta.h"

@interface LFSClientNetworkTests : SenTestCase
@end

@interface LFSClientNetworkTests()
@property (nonatomic) NSString *event;
@property (readwrite, nonatomic, strong) LFSBoostrapClient *client;
@property (readwrite, nonatomic, strong) LFSBoostrapClient *clientLabs;
@property (readwrite, nonatomic, strong) LFSAdminClient *clientAdmin;
@property (readwrite, nonatomic, strong) LFSWriteClient *clientWrite;
@end

@implementation LFSClientNetworkTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    if (![LFSConfig objectForKey:@"domain"]) {
        STFail(@"No test settings");
    }
    
    self.client = [LFSBoostrapClient clientWithEnvironment:[LFSConfig objectForKey:@"environment"]
                                                   network:[LFSConfig objectForKey:@"domain"]];
    self.clientLabs = [LFSBoostrapClient clientWithEnvironment:[LFSConfig objectForKey:@"environment"] network:[LFSConfig objectForKey:@"labs network"]];
    
    self.clientAdmin = [LFSAdminClient clientWithEnvironment:nil network:[LFSConfig objectForKey:@"domain"]];
    
    self.clientWrite = [LFSWriteClient clientWithEnvironment:nil network:[LFSConfig objectForKey:@"domain"]];
    
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
    
    [LFOldBootstrapClient getInitForArticle:[LFSConfig objectForKey:@"article"]
                                    site:[LFSConfig objectForKey:@"site"]
                                 network:[LFSConfig objectForKey:@"domain"]
                             environment:[LFSConfig objectForKey:@"environment"]
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
    self.event = [[coll objectForKey:LFSCollectionSettings] objectForKey:@"event"];
    STAssertNotNil(self.event, @"Should have fetched a head document");
}

- (void)testInitWithLFJSONRequestOperation
{
    __block id result = nil;
    
    // Most complicated way to use LFHTTPClient... Nevertheless it should work
    NSString* path = [NSString stringWithFormat:@"/bs3/%@/%@/%@/init",
                      [LFSConfig objectForKey:@"domain"],
                      [LFSConfig objectForKey:@"site"],
                      [[LFSConfig objectForKey:@"article"] base64String]];
    NSURLRequest *request = [self.client requestWithMethod:@"GET" path:path parameters:nil];
    LFSJSONRequestOperation *op = [LFSJSONRequestOperation
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
                      [LFSConfig objectForKey:@"domain"],
                      [LFSConfig objectForKey:@"site"],
                      [[LFSConfig objectForKey:@"article"] base64String]];
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
    expect(op).to.beInstanceOf([LFSJSONRequestOperation class]);
    expect(op.error).notTo.equal(NSURLErrorTimedOut);
    // Collection dictionary should have 4 keys: headDocument, collectionSettings, networkSettings, siteSettings
    expect(result).to.haveCountOf(4);
}

- (void)testInitWithGetInitForArticle
{
    //Note: this test fails when the URL is wrong (the way it's meant to be)
    __block LFSJSONRequestOperation *op = nil;
    __block id result = nil;
    
    // This is the easiest way to use LFHTTPClient
    [self.client getInitForSite:[LFSConfig objectForKey:@"site"]
                        article:[LFSConfig objectForKey:@"article"]
                      onSuccess:^(NSOperation *operation, id JSON){
                          op = (LFSJSONRequestOperation*)operation;
                          result = JSON;
                      }
                      onFailure:^(NSOperation *operation, NSError *error) {
                          op = (LFSJSONRequestOperation*)operation;
                          NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                      }
     ];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    expect(op).to.beInstanceOf([LFSJSONRequestOperation class]);
    expect(op.error).notTo.equal(NSURLErrorTimedOut);
    // Collection dictionary should have 4 keys: headDocument, collectionSettings, networkSettings, siteSettings
    expect(result).to.haveCountOf(4);
}

#pragma mark - Retrieve Hottest Collections
- (void)testHeatAPIResultRetrieval
{
    __block NSArray *res = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    [LFOldBootstrapClient getHottestCollectionsForTag:@"tag"
                                              site:[LFSConfig objectForKey:@"site"]
                                           network:[LFSConfig objectForKey:@"domain"]
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
    //Note: this test fails when the URL is wrong (the way it's meant to be)
    __block LFSJSONRequestOperation *op = nil;
    __block NSArray *result = nil;
    
    // Actual call would look something like this:
    [self.client getHottestCollectionsForSite:[LFSConfig objectForKey:@"site"]
                                          tag:@"tag"
                               desiredResults:10u
                                    onSuccess:^(NSOperation *operation, id responseObject) {
                                        op = (LFSJSONRequestOperation *)operation;
                                        result = (NSArray *)responseObject;
                                    } onFailure:^(NSOperation *operation, NSError *error) {
                                        op = (LFSJSONRequestOperation *)operation;
                                        NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                                    }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    expect(op).to.beInstanceOf([LFSJSONRequestOperation class]);
    expect(op.error).notTo.equal(NSURLErrorTimedOut);
    expect(result).to.beTruthy();
}

#pragma mark - Retrieve User Data
- (void)testUserDataRetrieval {
    __block NSArray *res = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [LFOldBootstrapClient getUserContentForUser:[LFSConfig objectForKey:@"system user"]
                                   withToken:nil
                                  forNetwork:[LFSConfig objectForKey:@"labs network"]
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

- (void)testUserDataRetrievalHTTP
{
    //Note: this test fails when the URL is wrong (the way it's meant to be)
    __block LFSJSONRequestOperation *op = nil;
    __block NSArray *result = nil;
    
    // Actual call would look something like this:
    [self.clientLabs getUserContentForUser:[LFSConfig objectForKey:@"system user"]
                                     token:nil statuses:nil offset:0 onSuccess:^(NSOperation *operation, id responseObject) {
                                         op = (LFSJSONRequestOperation *)operation;
                                         result = (NSArray *)responseObject;
                                     } onFailure:^(NSOperation *operation, NSError *error) {
                                         op = (LFSJSONRequestOperation *)operation;
                                         NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                                     }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    expect(op).to.beInstanceOf([LFSJSONRequestOperation class]);
    expect(op.error).notTo.equal(NSURLErrorTimedOut);
    expect(result).to.beTruthy();
}

#pragma mark - Test user authentication
- (void)testUserAuthenticationSiteArticle {
    //with article and site ids
    __block NSDictionary *res = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSString *userToken = [LFSConfig objectForKey:@"moderator user auth token"];
    
    [LFOldAdminClient authenticateUserWithToken:userToken
                                     article:[LFSConfig objectForKey:@"article"]
                                        site:[LFSConfig objectForKey:@"site"]
                                     network:[LFSConfig objectForKey:@"domain"]
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

- (void)testUserAuthenticationSiteArticleHTTP {
    //with collection id
    __block LFSJSONRequestOperation *op = nil;
    __block NSDictionary *result = nil;
    
    NSString *userToken = [LFSConfig objectForKey:@"moderator user auth token"];
    
    [self.clientAdmin authenticateUserWithToken:userToken
                                           site:[LFSConfig objectForKey:@"site"]
                                        article:[LFSConfig objectForKey:@"article"]
                                      onSuccess:^(NSOperation *operation, id responseObject) {
                                          op = (LFSJSONRequestOperation *)operation;
                                          result = (NSDictionary *)responseObject;
                                      }
                                      onFailure:^(NSOperation *operation, NSError *error) {
                                          op = (LFSJSONRequestOperation *)operation;
                                          NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                                      }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    expect(op).to.beInstanceOf([LFSJSONRequestOperation class]);
    expect(op.error).notTo.equal(NSURLErrorTimedOut);
}


#pragma mark -
- (void)testUserAuthenticationCollection {
    //with collection id
    __block NSDictionary *res = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSString *userToken = [LFSConfig objectForKey:@"moderator user auth token"];
    
    [LFOldAdminClient authenticateUserWithToken:userToken
                                  collection:[LFSConfig objectForKey:@"collection"]
                                     network:[LFSConfig objectForKey:@"domain"]
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

- (void)testUserAuthenticationCollectionHTTP {
    //with collection id
    __block LFSJSONRequestOperation *op = nil;
    __block NSDictionary *result = nil;
    
    NSString *userToken = [LFSConfig objectForKey:@"moderator user auth token"];
    
    [self.clientAdmin authenticateUserWithToken:userToken
                                     collection:[LFSConfig objectForKey:@"collection"]
                                      onSuccess:^(NSOperation *operation, id responseObject) {
                                          op = (LFSJSONRequestOperation *)operation;
                                          result = (NSDictionary *)responseObject;
                                      }
                                      onFailure:^(NSOperation *operation, NSError *error) {
                                          op = (LFSJSONRequestOperation *)operation;
                                          NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                                      }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    expect(op).to.beInstanceOf([LFSJSONRequestOperation class]);
    expect(op.error).notTo.equal(NSURLErrorTimedOut);
}

#pragma mark -
- (void)testLikes {
    __block NSDictionary *res = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSString *userToken = [LFSConfig objectForKey:@"moderator user auth token"];
    
    [LFOldWriteClient likeContent:[LFSConfig objectForKey:@"content"]
                       forUser:userToken
                    collection:[LFSConfig objectForKey:@"collection"]
                       network:[LFSConfig objectForKey:@"domain"]
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

- (void)testLikesHTTP {
    __block LFSJSONRequestOperation *op = nil;
    __block NSDictionary *result = nil;
    
    [self.clientWrite postOpinion:LFSOpinionLike
                          forUser:[LFSConfig objectForKey:@"moderator user auth token"]
                       forContent:[LFSConfig objectForKey:@"content"]
                     inCollection:[LFSConfig objectForKey:@"collection"]
                        onSuccess:^(NSOperation *operation, id responseObject) {
                            op = (LFSJSONRequestOperation *)operation;
                            result = (NSDictionary *)responseObject;
                        }
                        onFailure:^(NSOperation *operation, NSError *error) {
                            op = (LFSJSONRequestOperation *)operation;
                            NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                        }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    expect(op).to.beInstanceOf([LFSJSONRequestOperation class]);
    expect(op.error).notTo.equal(NSURLErrorTimedOut);
}

#pragma mark -
- (void)testUnlikes {
    __block NSDictionary *res = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSString *userToken = [LFSConfig objectForKey:@"moderator user auth token"];
    
    [LFOldWriteClient unlikeContent:[LFSConfig objectForKey:@"content"]
                         forUser:userToken
                      collection:[LFSConfig objectForKey:@"collection"]
                         network:[LFSConfig objectForKey:@"domain"]
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

- (void)testUnlikesHTTP {
    __block LFSJSONRequestOperation *op = nil;
    __block NSDictionary *result = nil;
    
    [self.clientWrite postOpinion:LFSOpinionUnlike
                          forUser:[LFSConfig objectForKey:@"moderator user auth token"]
                       forContent:[LFSConfig objectForKey:@"content"]
                     inCollection:[LFSConfig objectForKey:@"collection"]
                        onSuccess:^(NSOperation *operation, id responseObject) {
                            op = (LFSJSONRequestOperation *)operation;
                            result = (NSDictionary *)responseObject;
                        }
                        onFailure:^(NSOperation *operation, NSError *error) {
                            op = (LFSJSONRequestOperation *)operation;
                            NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                        }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    expect(op).to.beInstanceOf([LFSJSONRequestOperation class]);
    expect(op.error).notTo.equal(NSURLErrorTimedOut);
}

#pragma mark -
- (void)testPost {
    __block NSDictionary *res = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    NSString *content = [NSString stringWithFormat:@"test post, %d", arc4random()];
    [LFOldWriteClient postContent:content
                       forUser:[LFSConfig objectForKey:@"moderator user auth token"]
                     inReplyTo:nil
                 forCollection:[LFSConfig objectForKey:@"collection"]
                       network:[LFSConfig objectForKey:@"domain"]
                     onSuccess:^(NSDictionary *content) {
                         res = content;
                         dispatch_semaphore_signal(sema);
                     }
                     onFailure:^(NSError *error) {
                         NSLog(@"Error code %d, with description %@",
                               error.code,
                               [error localizedDescription]);
                         dispatch_semaphore_signal(sema);
                     }];
    
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    STAssertEqualObjects([res objectForKey:@"status"], @"ok", @"This response should have been ok");
}

- (void)testPostHTTP
{
    //Note: this test fails when the URL is wrong (the way it's meant to be)
    __block LFSJSONRequestOperation *op = nil;
    __block id result = nil;
    
    // Actual call would look something like this:
    [self.clientWrite postNewContent:[NSString stringWithFormat:@"test post, %d", arc4random()]
                             forUser:[LFSConfig objectForKey:@"moderator user auth token"]
                       forCollection:[LFSConfig objectForKey:@"collection"]
                           inReplyTo:nil
                           onSuccess:^(NSOperation *operation, id responseObject) {
                               op = (LFSJSONRequestOperation*)operation;
                               result = responseObject;
                           }
                           onFailure:^(NSOperation *operation, NSError *error) {
                               op = (LFSJSONRequestOperation*)operation;
                               NSLog(@"Error code %d, with description %@",
                                     error.code,
                                     [error localizedDescription]);
                           }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    expect(op).to.beInstanceOf([LFSJSONRequestOperation class]);
    expect(op.error).notTo.equal(NSURLErrorTimedOut);
    expect(result).to.beTruthy();
}

#pragma mark -
- (void)testPostInReplyTo {
    //in reply to
    __block NSDictionary *res = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSString *parent = [LFSConfig objectForKey:@"content"];
    [LFOldWriteClient postContent:[NSString stringWithFormat:@"test reply, %d", arc4random()]
                       forUser:[LFSConfig objectForKey:@"moderator user auth token"]
                     inReplyTo:parent
                 forCollection:[LFSConfig objectForKey:@"collection"]
                       network:[LFSConfig objectForKey:@"domain"]
                     onSuccess:^(NSDictionary *content) {
                         res = content;
                         dispatch_semaphore_signal(sema);
                     } onFailure:^(NSError *error) {
                         NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                         dispatch_semaphore_signal(sema);
                     }];
    
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    
    NSString *parent1 = [[[res valueForKeyPath:@"data.messages"] objectAtIndex:0]
                         valueForKeyPath:@"content.parentId"];
    STAssertEqualObjects(parent1, parent, @"This response should have been a child.");
}

- (void)testPostInReplyToHTTP
{
    //Note: this test fails when the URL is wrong (the way it's meant to be)
    __block LFSJSONRequestOperation *op = nil;
    __block id result = nil;
    
    NSString *parent = [LFSConfig objectForKey:@"content"];
    
    // Actual call would look something like this:
    [self.clientWrite postNewContent:[NSString stringWithFormat:@"test reply, %d", arc4random()]
                             forUser:[LFSConfig objectForKey:@"moderator user auth token"]
                       forCollection:[LFSConfig objectForKey:@"collection"]
                           inReplyTo:parent
                           onSuccess:^(NSOperation *operation, id responseObject) {
                               op = (LFSJSONRequestOperation*)operation;
                               result = responseObject;
                           }
                           onFailure:^(NSOperation *operation, NSError *error) {
                               op = (LFSJSONRequestOperation*)operation;
                               NSLog(@"Error code %d, with description %@",
                                     error.code,
                                     [error localizedDescription]);
                           }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    expect(op).to.beInstanceOf([LFSJSONRequestOperation class]);
    expect(op.error).notTo.equal(NSURLErrorTimedOut);
    expect(result).to.beTruthy();
    NSString *parent1 = [[[result objectForKey:@"messages"] objectAtIndex:0]
                         valueForKeyPath:@"content.parentId"];
    expect(parent1).to.equal(parent);
}

#pragma mark -
- (void)testFlag {
    __block NSDictionary *res = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    [LFOldWriteClient flagContent:[LFSConfig objectForKey:@"content"]
                 forCollection:[LFSConfig objectForKey:@"collection"]
                       network:[LFSConfig objectForKey:@"domain"]
                      withFlag:LFSFlagOfftopic
                          user:[LFSConfig objectForKey:@"moderator user auth token"]
                         notes:@"fakeNotes"
                         email:@"fakeEmail"
                     onSuccess:^(NSDictionary *opineData) {
                         res = opineData;
                         dispatch_semaphore_signal(sema);
                     } onFailure:^(NSError *error) {
                         NSLog(@"Error code %d, with description %@",
                               error.code,
                               [error localizedDescription]);
                         dispatch_semaphore_signal(sema);
                     }];
    
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    STAssertEqualObjects([res objectForKey:@"status"], @"ok", @"This response should have been ok");
}

- (void)testFlagHTTP
{
    //Note: this test fails when the URL is wrong (the way it's meant to be)
    __block LFSJSONRequestOperation *op = nil;
    __block id result = nil;
    
    // Actual call would look something like this:
    [self.clientWrite postFlag:LFSFlagOfftopic
                       forUser:[LFSConfig objectForKey:@"moderator user auth token"]
                    forContent:[LFSConfig objectForKey:@"content"]
                  inCollection:[LFSConfig objectForKey:@"collection"]
                    parameters:@{@"notes":@"fakeNotes", @"email":@"fakeEmail"}
                     onSuccess:^(NSOperation *operation, id responseObject) {
                         op = (LFSJSONRequestOperation*)operation;
                         result = responseObject;
                     }
                     onFailure:^(NSOperation *operation, NSError *error) {
                         op = (LFSJSONRequestOperation*)operation;
                         NSLog(@"Error code %d, with description %@",
                               error.code,
                               [error localizedDescription]);
                     }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    expect(op).to.beInstanceOf([LFSJSONRequestOperation class]);
    expect(op.error).notTo.equal(NSURLErrorTimedOut);
    expect(result).to.beTruthy();
}

#pragma mark -
- (void)testCreateCollectionWithSecretHTTP
{
    //Note: this test fails when the URL is wrong (the way it's meant to be)
    __block LFSJSONRequestOperation *op = nil;
    __block id result = nil;
    
    // Modify article Id to a unique one to avoid error 409
    [self.clientWrite postNewArticle:@"justTesting7"
                             forSite:[LFSConfig objectForKey:@"site"]
                       secretSiteKey:[LFSConfig objectForKey:@"site key"]
                               title:@"La la la la"
                                tags:@[@"hey", @"hello"]
                             withURL:[NSURL URLWithString:@"http://erere.com/ererereer"]
                           onSuccess:^(NSOperation *operation, id responseObject) {
                               op = (LFSJSONRequestOperation*)operation;
                               result = responseObject;
                           }
                           onFailure:^(NSOperation *operation, NSError *error) {
                               op = (LFSJSONRequestOperation*)operation;
                               NSLog(@"Error code %d. Description: %@. Recovery Suggestion: %@",
                                     error.code,
                                     [error localizedDescription],
                                     [error localizedRecoverySuggestion]);
                           }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    expect(op).to.beInstanceOf([LFSJSONRequestOperation class]);
    expect(op.error).notTo.equal(NSURLErrorTimedOut);
    if (op.error) {
        // HTTP 409: Collection already exists for site_id ... and article_id .... Use update instead.
        expect(op.response.statusCode).to.equal(409);
    } else {
        // HTTP 202: This request is being processed.
        expect(op.response.statusCode).to.equal(202);
    }
}

- (void)testCreateCollectionUnsignedHTTP
{
    //Note: this test fails when the URL is wrong (the way it's meant to be)
    __block LFSJSONRequestOperation *op = nil;
    __block id result = nil;
    
    // Modify article Id to a unique one to avoid error 409
    [self.clientWrite postNewArticle:@"justTesting8"
                             forSite:[LFSConfig objectForKey:@"site"]
                       secretSiteKey:nil
                               title:@"La la la la"
                                tags:@[@"hey", @"hello"]
                             withURL:[NSURL URLWithString:@"http://erere.com/ererereer"]
                           onSuccess:^(NSOperation *operation, id responseObject) {
                               op = (LFSJSONRequestOperation*)operation;
                               result = responseObject;
                           }
                           onFailure:^(NSOperation *operation, NSError *error) {
                               op = (LFSJSONRequestOperation*)operation;
                               NSLog(@"Error code %d. Description: %@. Recovery Suggestion: %@",
                                     error.code,
                                     [error localizedDescription],
                                     [error localizedRecoverySuggestion]);
                           }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op.isFinished).will.beTruthy();
    expect(op).to.beInstanceOf([LFSJSONRequestOperation class]);
    expect(op.error).notTo.equal(NSURLErrorTimedOut);
    if (op.error) {
        // HTTP 409: Collection already exists for site_id ... and article_id .... Use update instead.
        expect(op.response.statusCode).to.equal(409);
    } else {
        // HTTP 202: This request is being processed.
        expect(op.response.statusCode).to.equal(202);
    }
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


@end
