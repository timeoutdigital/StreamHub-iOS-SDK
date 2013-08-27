//
//  NSString+LFSEref.h
//  LFClient
//
//  Created by Eugene Scherba on 8/27/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LFSEref)

/** @name eref decoding. */

/**
 * A method to assist with decoding content erefs using a Livefyre user's key or keys.
 *
 * @self   The eref to attempt to decode.
 * @param  keys The keys to apply to the encoded content.
 * @return NSString
 */
- (NSString *)decodeErefWithKeys:(NSArray *)keys;

/**
 * A method to assist with decoding Livefyre content ciphers.
 *
 * @self   The cipher text.
 * @param  key The secret key.
 * @return NSString
 */
- (NSString *)decryptRC4WithKey:(NSString *)key;

@end
