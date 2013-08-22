//
//  LFClientUnitTests.m
//  LFClient
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


#import "LFClientUnitTests.h"
#import "LFTestingURLProtocol.h"
#import "LFClient.h"
#import "LFConfig.h"
#import "JSONKit.h"
#import "LFHTTPClient.h"

#define EXP_SHORTHAND YES
#import "Expecta.h"

@interface LFClientUnitTests()
@property (readwrite, nonatomic, strong) LFHTTPClient *client;
@end

@implementation LFClientUnitTests
- (void)setUp
{
    [super setUp];
    //These tests are nominal.
    [NSURLProtocol registerClass:[LFTestingURLProtocol class]];
    
    self.client = [[LFHTTPClient alloc] initWithEnvironment:nil network:@"init-sample"];
    
    // set timeout to 60 seconds
    [Expecta setAsynchronousTestTimeout:60.0f];
}

- (void)tearDown
{
    // Tear-down code here.
    [NSURLProtocol unregisterClass:[LFTestingURLProtocol class]];

    // cancelling all operations just in case (not strictly required)
    for (NSOperation *operation in self.client.operationQueue.operations) {
        [operation cancel];
    }
    self.client = nil;
    
    [super tearDown];
}

#pragma mark - Test Bootstrap Client
- (void)testBootstrapClientGetPages {
    // Get Init
    __block NSDictionary *bootstrapInitInfo = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    [LFBootstrapClient getInitForArticle:@"fakeArticle"
                                    site:@"fakeSite"
                                 network:@"init-sample"
                             environment:nil
                               onSuccess:^(NSDictionary *collection) {
                                     bootstrapInitInfo = collection;
                                     dispatch_semaphore_signal(sema);
                                 }
                               onFailure:^(NSError *error) {
                                     if (error)
                                         NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                                     dispatch_semaphore_signal(sema);
                                 }];
    
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    STAssertEquals([bootstrapInitInfo count], 4u, @"Collection dictionary should have 4 keys");

    // Get Content
    __block NSDictionary *contentInfo = nil;
    sema = dispatch_semaphore_create(0);
    
    [LFBootstrapClient getContentForPage:0
                            withInitInfo:bootstrapInitInfo
                               onSuccess:^(NSDictionary *content) {
                                     contentInfo = content;
                                     dispatch_semaphore_signal(sema);
                                 }
                               onFailure:^(NSError *error) {
                                     if (error)
                                         NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                                     dispatch_semaphore_signal(sema);
                                 }];
    
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    STAssertNotNil(contentInfo, @"Content head document fail");
    
    sema = dispatch_semaphore_create(0);
    
    [LFBootstrapClient getContentForPage:1
                            withInitInfo:bootstrapInitInfo
                               onSuccess:^(NSDictionary *content) {
                                     contentInfo = content;
                                     dispatch_semaphore_signal(sema);
                                 }
                               onFailure:^(NSError *error) {
                                     if (error)
                                         NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                                     dispatch_semaphore_signal(sema);
                                 }];
    
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    STAssertNotNil(contentInfo, @"Content fetch fail");
}


- (void)testLFHTTPClient
{
    // Get Init
    __block NSDictionary *bootstrapInitInfo = nil;
    __block LFJSONRequestOperation *op0 = nil;
    
    // This is the easiest way to use LFHTTPClient
    [self.client getInitForSite:@"fakeSite"
                        article:@"fakeArticle"
                      onSuccess:^(NSOperation *operation, id JSON){
                          op0 = (LFJSONRequestOperation*)operation; bootstrapInitInfo = JSON;
                      }
                      onFailure:^(NSOperation *operation, NSError *error) {
                          op0 = (LFJSONRequestOperation*)operation;
                          NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                      }
     ];
    
    // Wait 'til done and then verify that everything is OK
    expect(op0.isFinished).will.beTruthy();
    expect(op0).to.beInstanceOf([LFJSONRequestOperation class]);
    expect(op0.error).notTo.equal(NSURLErrorTimedOut);
    // Collection dictionary should have 4 keys: headDocument, collectionSettings, networkSettings, siteSettings
    expect(bootstrapInitInfo).to.haveCountOf(4);
    
    
    // Get Page 1
    __block NSDictionary *contentInfo1 = nil;
    __block LFJSONRequestOperation *op1 = nil;
    [self.client getContentWithInit:bootstrapInitInfo
                               page:0
                          onSuccess:^(NSOperation *operation, id JSON){
                              op1 = (LFJSONRequestOperation*)operation; contentInfo1 = JSON;
                          }
                          onFailure:^(NSOperation *operation, NSError *error) {
                              op1 = (LFJSONRequestOperation*)operation;
                              NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                          }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op1.isFinished).will.beTruthy();
    //expect(op1).to.beInstanceOf([LFJSONRequestOperation class]);
    //expect(op1.error).notTo.equal(NSURLErrorTimedOut);
    expect(contentInfo1).to.beTruthy();
    
    // Get Page 2
    __block NSDictionary *contentInfo2 = nil;
    __block LFJSONRequestOperation *op2 = nil;
    [self.client getContentWithInit:bootstrapInitInfo
                               page:1
                          onSuccess:^(NSOperation *operation, id JSON){
                              op2 = (LFJSONRequestOperation*)operation; contentInfo2 = JSON;
                          }
                          onFailure:^(NSOperation *operation, NSError *error) {
                              op2 = (LFJSONRequestOperation*)operation;
                              NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                          }];
    
    // Wait 'til done and then verify that everything is OK
    expect(op2.isFinished).will.beTruthy();
    expect(op2).to.beInstanceOf([LFJSONRequestOperation class]);
    expect(op2.error).notTo.equal(NSURLErrorTimedOut);
    expect(contentInfo2).to.beTruthy();
}

#pragma mark -
- (void)testPublicAPIGetTrending {
    __block NSArray *res = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    [LFBootstrapClient getHottestCollectionsForTag:@"taggy"
                                              site:@"site"
                                           network:@"hottest-sample"
                                    desiredResults:10u
                                         onSuccess:^(NSArray *results) {
                                                res = results;
                                                dispatch_semaphore_signal(sema);
                                         } onFailure:^(NSError *error) {
                                                NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                                                dispatch_semaphore_signal(sema);
                                            }];
    
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    
    STAssertEquals([res count], 10u, @"Heat API should return 10 items");
}

- (void)testUserDataRetrieval {
    __block NSArray *res = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [LFBootstrapClient getUserContentForUser:@"fakeUser"
                                   withToken:nil
                                   forNetwork:@"usercontent-sample"
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
    
    STAssertEquals([res count], 12u, @"User content API should return 12 items");
}

- (void)testUserAuthentication {
    //with article and site ids
    __block NSDictionary *res = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    [LFAdminClient authenticateUserWithToken:@"fakeToken"
                               forCollection:@"fakeColl"
                                     article:nil
                                        site:nil
                                     network:@"auth-sample"
                                   onSuccess:^(NSDictionary *gotUserData) {
                                         res = gotUserData;
                                         dispatch_semaphore_signal(sema);
                                } onFailure:^(NSError *error) {
                                         NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                                         dispatch_semaphore_signal(sema);
                                     }];
    
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));

    STAssertEquals([res count], 3u, @"User auth should return 3 items");
}

- (void)testLikes {
    __block NSDictionary *res = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    [LFWriteClient likeContent:@"fakeContent"
                       forUser:@"fakeUserToken"
                    collection:@"fakeColl"
                       network:@"like-sample"
                     onSuccess:^(NSDictionary *content) {
                           res = content;
                           dispatch_semaphore_signal(sema);
                   } onFailure:^(NSError *error) {
                           NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                           dispatch_semaphore_signal(sema);
                       }];
    
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    
    STAssertEquals([res count], 3u, @"Like action should return 3 items");
}

- (void)testPost {
    __block NSDictionary *res = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSUInteger ran = arc4random();
    
    [LFWriteClient postContent:[NSString stringWithFormat:@"test post, %d", ran]
                       forUser:@"fakeUser"
                     inReplyTo:nil
                 forCollection:@"fakeColl"
                       network:@"post-sample"
                     onSuccess:^(NSDictionary *content) {
                           res = content;
                           dispatch_semaphore_signal(sema);
                   } onFailure:^(NSError *error) {
                           NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                           dispatch_semaphore_signal(sema);
                       }];
    
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    
    STAssertEquals([res count], 3u, @"Post content should return 3 items");
}


- (void)testFlag {
    __block NSDictionary *res = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

    [LFWriteClient flagContent:@"fakeContent"
                 forCollection:@"fakeCollection"
                       network:@"flag-sample"
                      withFlag:OFF_TOPIC
                          user:@"fakeUser"
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

    STAssertEquals([res count], 3u, @"Post content should return 3 items");
}

//- (void)testStream {
//    __block NSDictionary *res = nil;
//    __block NSUInteger trips = 2;
//    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
//     
//    LFStreamClient *streamer = [LFStreamClient new];
//    [streamer startStreamForCollection:@"fakeColl"
//                             fromEvent:@"fakeId"
//                             onNetwork:@"stream-sample"
//                               success:^(NSDictionary *updates) {
//                                   res = updates;
//                                   trips--;
//                                   if (trips == 0)
//                                       dispatch_semaphore_signal(sema);
//                               } failure:^(NSError *error) {
//                                   NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
//                                   dispatch_semaphore_signal(sema);
//                               }];
//    
//    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
//    STAssertEquals([res count], 3u, @"Stream should return 3 items");
//    
//    [streamer stopStreamForCollection:@"fakeColl"];
//    res = nil;
//    //Stop stream will stop, but due to async magic there is no gaurantee when it will stop.
//    //dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
//    STAssertNil(res, @"Stop stream should stop the stream");
//}

/*
- (void)testNumber
{
    NSString *spoofPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"number-test" ofType:@"json"];
    NSData *responseData = [[NSData alloc] initWithContentsOfFile:spoofPath];
    NSError *error;
    id parsedData = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    STAssertNotNil(parsedData, @"no error");
    STAssertNil(error, @"no error");
}
*/


- (void)testNumberJSONKit
{
    NSString *spoofPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"number-test" ofType:@"json"];
    NSData *responseData = [[NSData alloc] initWithContentsOfFile:spoofPath];
    NSError *error = nil;
    JSONDecoder *decoder = [JSONDecoder decoderWithParseOptions:JKParseOptionTruncateNumbers];
    id parsedData = [decoder objectWithData:responseData error:&error];
    STAssertNotNil(parsedData, @"no error");
    STAssertNil(error, @"no error");
}

@end
