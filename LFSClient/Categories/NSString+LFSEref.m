//
//  NSString+LFSEref.m
//  LFSClient
//
//  Created by Eugene Scherba on 8/27/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "NSString+LFSEref.h"
#import <CommonCrypto/CommonCryptor.h>

static NSData *hexStringToBytes(NSString *string)
{
    NSMutableData *data = [NSMutableData data];
    for (NSUInteger i = 0; i + 2 <= string.length; i += 2) {
        uint8_t value = (uint8_t)strtol([[string substringWithRange:NSMakeRange(i, 2)] UTF8String], 0, 16);
        [data appendBytes:&value length:1];
    }
    return data;
}

@implementation NSString (LFSEref)

- (NSString *)decryptRC4WithKey:(NSString *)key
{
    NSData *inBytes = hexStringToBytes(self);
    NSData *keyBytes = hexStringToBytes(key);
    
    NSMutableData *outBytes = [NSMutableData dataWithLength:[inBytes length]];
    size_t dataOutMoved = 0;
    
    CCCryptorStatus ccStatus = CCCrypt(kCCDecrypt,
                                       kCCAlgorithmRC4,
                                       0,
                                       [keyBytes bytes],
                                       [keyBytes length],
                                       NULL, // iv
                                       [inBytes bytes],
                                       [inBytes length],
                                       [outBytes mutableBytes],
                                       [outBytes length],
                                       &dataOutMoved);
    
    NSString *decrypted = [[NSString alloc] initWithData:outBytes encoding:NSUTF8StringEncoding];
    
    if (ccStatus == kCCSuccess) {
        return decrypted;
    }
    return self;
}

- (NSString *)decodeErefWithKeys:(NSArray *)keys {
    for (NSString *key in keys) {
        NSString *decryptedPath = [self decryptRC4WithKey:key];
        if ([decryptedPath hasPrefix:@"eref://"]) {
            return decryptedPath;
        }
    }
    return nil;
}

@end
