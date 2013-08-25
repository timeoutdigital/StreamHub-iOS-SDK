//
//  LFConstants.h
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

#import <Foundation/Foundation.h>

//TODO add constants and enums to appledoc.
@interface LFConstants : NSObject

extern NSString *const LFSScheme;
extern NSString *const LFSErrorDomain;


// user content preferences (like, unlike, etc)
typedef NS_ENUM(NSUInteger, LFSOpinion) {
    LFSOpinionLike = 0u,
    LFSOpinionUnlike
};

// moderator content flags
typedef NS_ENUM(NSUInteger, LFSUserFlag) {
    LFSFlagOffensive = 0u,
    LFSFlagSpam,
    LFSFlagDisagree,
    LFSFlagOfftopic
};


/*
extern NSString *const kShareTypeTwitter;
extern NSString *const kShareTypeFacebook;
extern NSString *const kShareTypeLinkedin;
//
extern NSString *const kCommentStatusActive;
extern NSString *const kCommentStatusBozo;
extern NSString *const kCommentStatusPending;
extern NSString *const kCommentStatusSpam;
extern NSString *const kCommentStatusHidden;
extern NSString *const kCommentStatusDeleted;
*/


/*
typedef NS_ENUM(NSUInteger, LFSContentType) {
    LFSContentTypeMessage = 0u, //A message posted by a user in reply to an article or another comment
    LFSContentTypeOpine, // An opinion from a user indicating that they like a comment or an embed
    LFSContentTypeEmbed // An embedded image which is part of a comment
};

typedef NS_ENUM(NSUInteger, LFSContentVisibility) {
    LFSContentVisibilityNone = 0u, //content is visible to no one, usually due to being deleted
    LFSContentVisibilityEveryone, //content is visible to everyone
    LFSContentVisibilityOwner, //content is visible to only the author due to bozoing
    LFSContentVisibilityGroup //content is visible to the author and any moderators for the
    // collection, usually meaning that it's waiting for approval
};

typedef NS_ENUM(NSUInteger, LFSPermissions) {
    LFSPermissionsNone = 0u,
    LFSPermissionsWhitelist,
    LFSPermissionsBlacklist,
    LFSPermissionsGraylist,
    LFSPermissionsModerator
};

typedef NS_ENUM(NSUInteger, LFSPermissionScope) {
    LFSPermissionScopeGlobal = 0u,
    LFSPermissionScopeNetwork,
    LFSPermissionScopeSite,
    LFSPermissionScopeCollection,
    LFSPermissionScopeCollectionRule
};
*/

@end
