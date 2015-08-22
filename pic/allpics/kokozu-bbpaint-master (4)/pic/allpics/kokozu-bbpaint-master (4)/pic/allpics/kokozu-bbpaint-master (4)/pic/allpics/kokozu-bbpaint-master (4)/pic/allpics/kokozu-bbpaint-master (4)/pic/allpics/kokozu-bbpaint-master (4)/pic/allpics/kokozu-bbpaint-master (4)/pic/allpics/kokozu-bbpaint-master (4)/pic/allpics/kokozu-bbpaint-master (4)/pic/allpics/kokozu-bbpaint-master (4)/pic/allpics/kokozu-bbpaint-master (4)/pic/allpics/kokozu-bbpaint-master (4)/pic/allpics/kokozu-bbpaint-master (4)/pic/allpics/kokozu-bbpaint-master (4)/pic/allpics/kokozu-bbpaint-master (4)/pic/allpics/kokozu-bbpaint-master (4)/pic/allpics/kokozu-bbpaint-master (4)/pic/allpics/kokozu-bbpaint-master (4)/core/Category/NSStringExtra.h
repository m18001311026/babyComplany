//
//  NSStringExtra.h
//  alfaromeo.dev
//
//  Created by zhang da on 10-9-27.
//  Copyright 2010 alfaromeo.dev inc. All rights reserved.
//

@interface NSString (Extra)

- (NSString *)URLEncodedString;
- (NSString *)URLDecodedString;
- (NSDictionary *)URLParams;

- (NSString*)escapeHTML;
- (NSString*)unescapeHTML;

- (BOOL)isNumeric;

- (NSString *)String2Base64;
- (NSString *)Base642String:(NSStringEncoding)encoding;

- (NSString *)MD5String;
- (NSString *)MD5String16;

- (NSString *)desEncryptWithKey:(NSString *)key;
- (NSString *)desDecryptWithKey:(NSString *)key;

@end
