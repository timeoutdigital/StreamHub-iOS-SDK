//
//  LFHTTPClient.h
//  
//
//  Created by Eugene Scherba on 8/20/13.
//
//

#import "AFHTTPClient.h"
#import "LFJSONRequestOperation.h"

typedef void (^LFSuccessBlock) (NSOperation *operation, id responseObject);
typedef void (^LFFailureBlock) (NSOperation *operation, NSError *error);
typedef void (^AFSuccessBlock) (AFHTTPRequestOperation *operation, id responseObject);
typedef void (^AFFailureBlock) (AFHTTPRequestOperation *operation, NSError *error);

@interface LFHTTPClient : AFHTTPClient

/**
 * Initialize Livefyre client
 *
 * @param networkDomain The collection's network as identified by domain, i.e. livefyre.com.
 * @param environment (optional) Where the collection is hosted, i.e. t-402. Used for development/testing purposes.
 * @return LFClient instance
 */

- (id)initWithEnvironment:(NSString *)environment
                  network:(NSString *)network;

/**
 * Get the initial bootstrap data for a collection.
 *
 * For more information see:
 * https://github.com/Livefyre/livefyre-docs/wiki/StreamHub-API-Reference#wiki-init
 *
 * @param articleId The Id of the collection's article.
 * @param siteId The Id of the article's site.
 * @param success Callback called with a dictionary after the init data has been retrieved.
 * @param failure Callback called with an error after a failure to retrieve data.
 * @return void
 */
- (void)getInitForSite:(NSString *)siteId
               article:(NSString *)articleId
             onSuccess:(LFSuccessBlock)success
             onFailure:(LFFailureBlock)failure;

/** @name Heat Index Trends */

/**
 * Polls for hottest Collections
 *
 * For more information see:
 * https://github.com/Livefyre/livefyre-docs/wiki/Heat-Index-API
 *
 * @param site (optional) Site ID to filter on.
 * @param tag (optional) Tag to filter on.
 * @param numberOfResults (optional) Number of results to be returned. The default is 10 and the maximum is 100.
 * @param success Callback called with a dictionary after the results data has been retrieved.
 * @param failure Callback called with an error after a failure to retrieve data.
 * @return void
 */
- (void)getHottestCollectionsForSite:(NSString *)siteId
                                 tag:(NSString *)tag
                      desiredResults:(NSUInteger)number
                           onSuccess:(LFSuccessBlock)success
                           onFailure:(LFFailureBlock)failure;

/** @name Content Retrieval */

/**
 * The init data for a collection contains information about that collection's number of pages and where to fetch the content for those pages.
 *
 * @param initInfo A pointer to a bootstrap's init data as returned by the bootstrap init endpoint and parsed from JSON into a dictionary.
 * @param pageIndex The page to fetch content for. The pages are numbered from zero. If the page index provided is outside the bounds of what the init data knows about the error callback will convey that failure.
 * @param success Callback called with a dictionary represting the pages content.
 * @param failure Callback called with an error after a failure to retrieve data.
 * @return void
 */
- (void)getContentWithInit:(NSDictionary *)initInfo
                      page:(NSInteger)pageIndex
                 onSuccess:(LFSuccessBlock)success
                 onFailure:(LFFailureBlock)failure;

@property (nonatomic, readonly, strong) NSString* lfEnvironment;
@property (nonatomic, readonly, strong) NSString* lfNetwork;

@end
