//
//  LFSConstants.m
//  LivefyreClient
//
//  Created by zjj on 1/9/13.
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

#import "LFSConstants.h"

@implementation LFSConstants

NSString* const LFSSystemVersion70 = @"7.0";

NSString *const LFSScheme = @"http";
NSString *const LFSErrorDomain = @"LFSErrorDomain";

// Various constants to help with parsing JSON files
NSString *const LFSCollectionSettings = @"collectionSettings";
NSString *const LFSHeadDocument = @"headDocument";
NSString *const LFSNetworkSettings = @"networkSettings";
NSString *const LFSSiteSettings = @"siteSettings";

// (for internal use):
// https://github.com/Livefyre/lfdj/blob/production/lfwrite/lfwrite/api/v3_0/urls.py#L75
const NSString* const LFSMessageEndpoints[LFS_OPINE_ENDPOINTS_LENGTH] =
{
    @"edit",            // 0
    @"approve",         // 1
    @"unapprove",       // 2
    @"hide",            // 3
    @"unhide",          // 4
    @"delete",          // 5
    @"bozo",            // 6
    @"ignore-flags",    // 7
    @"add-note",        // 8
    
    @"like",            // 9
    @"unlike",          // 10
    @"flag",            // 11
    @"mention",         // 12
    @"share",           // 13
    @"vote"             // 14
};

// (for internal use):
// https://github.com/Livefyre/lfdj/blob/production/lfwrite/lfwrite/api/v3_0/urls.py#L87
const NSString* const LFSContentFlags[LFS_CONTENT_FLAGS_LENGTH] =
{
    @"spam",            // 0
    @"offensive",       // 1
    @"disagree",        // 2
    @"off-topic"        // 3
};

// {{{ Collection stream types
// https://github.com/Livefyre/lfdj/blob/production/lfcore/lfcore/v2/network/steps.py#L538
NSString *const LFSStreamTypeThreaded = @"threaded";
NSString *const LFSStreamTypeLiveComments = @"livecomments";
NSString *const LFSStreamTypeLiveChat = @"livechat";
NSString *const LFSStreamTypeLiveBlog = @"liveblog";
NSString *const LFSStreamTypeReviews = @"reviews";
NSString *const LFSStreamTypeLiveReviews = @"livereviews";
NSString *const LFSStreamTypeRatings = @"ratings";
NSString *const LFSStreamTypeStory = @"story";
NSString *const LFSStreamTypeCounting = @"counting";
// }}}

// {{{ Collection meta keys
// https://github.com/Livefyre/lfdj/blob/production/lfcore/lfcore/v2/network/steps.py#L478
NSString *const LFSCollectionMetaArticleIdKey = @"articleId";
NSString *const LFSCollectionMetaURLKey = @"url";
NSString *const LFSCollectionMetaTitleKey = @"title";
NSString *const LFSCollectionMetaTagsKey = @"tags";
NSString *const LFSCollectionMetaTypeKey = @"type";
// }}}


@end
