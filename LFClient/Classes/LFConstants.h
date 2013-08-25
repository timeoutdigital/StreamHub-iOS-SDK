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
//
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
//
extern NSString *const kStreamDomain;
extern NSString *const kAdminDomain;
extern NSString *const kBootstrapDomain;
extern NSString *const kQuillDomain;

// user content preferences (like, unlike, etc)
extern NSString* const LFSOpinionString[];
typedef NS_ENUM(NSUInteger, LFSOpinion) {
    LFSOpinionLike = 0u,
    LFSOpinionUnlike
};

// moderator content flags
extern NSString* const LFSUserFlagString[];
typedef NS_ENUM(NSUInteger, LFSUserFlag) {
    LFSFlagOffensive = 0u,
    LFSFlagSpam,
    LFSFlagDisagree,
    LFSFlagOfftopic
};

typedef NS_ENUM(NSUInteger, LFSContentType) {
    // A message posted by a user in reply to an article or another comment.
    LFSContentTypeMessage = 0u,
    // An opinion from a user indicating that they like a comment or an embed.
    LFSContentTypeOpine,
    // An embedded image which is part of a comment.
    LFSContentTypeEmbed
};

typedef NS_ENUM(NSUInteger, LFSContentVisibility) {
    // The content is visible to no one, usually due to being deleted.
    LFSContentVisibilityNone = 0,
    // The content is visible to everyone.
    LFSContentVisibilityEveryone = 1,
    // The content is visible to only the author due to bozoing.
    LFSContentVisibilityOwner = 2,
    // The content is visible to the author and any moderators for the
    // collection, usually meaning that it's waiting for approval.
    LFSContentVisibilityGroup = 3
};

typedef NS_ENUM(NSUInteger, LFSPermissions) {
    LFSPermissionsNone = 0,
    LFSPermissionsWhitelist = 1,
    LFSPermissionsBlacklist = 2,
    LFSPermissionsGraylist = 3,
    LFSPermissionsModerator = 4
};

typedef NS_ENUM(NSUInteger, LFSPermissionScope) {
    LFSPermissionScopeGlobal = 0,
    LFSPermissionScopeNetwork = 1,
    LFSPermissionScopeSite = 2,
    LFSPermissionScopeCollection = 3,
    LFSPermissionScopeCollectionRule = 4
};


@end
