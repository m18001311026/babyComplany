//
//  NSStringExtra.m
//  alfaromeo.dev
//
//  Created by zhang da on 10-9-27.
//  Copyright 2010 alfaromeo.dev inc. All rights reserved.
//

#import "NSStringExtra.h"
#import <CommonCrypto/CommonDigest.h>

static const char _base64EncodingTable[64] = { 
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
    'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
    'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
    'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/'
};
static const short _base64DecodingTable[256] = {
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
    -2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
    -2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};

@implementation NSString (Extra)

- (NSString *)URLEncodedString {
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)self,
                                                                           NULL,
																		   CFSTR("!*'~();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8);
    [result autorelease];
	return result;
}

- (NSString*)URLDecodedString {
	NSString *result = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
																						   (CFStringRef)self,
																						   CFSTR(""),
																						   kCFStringEncodingUTF8);
    [result autorelease];
	return result;	
}

- (NSString*)String2Base64 {
    if ([self length] == 0)
        return @"";
    
    const char *source = [self UTF8String];
    unsigned long strlength  = strlen(source);
    
    char *characters = (char *)malloc(((strlength + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    
    NSUInteger length = 0;
    NSUInteger i = 0;
    
    while (i < strlength) {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < strlength)
            buffer[bufferLength++] = source[i++];
        characters[length++] = _base64EncodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = _base64EncodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = _base64EncodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = _base64EncodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    
    return [[[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES] autorelease];

}

- (NSString *)Base642String:(NSStringEncoding)encoding {
    const char * objPointer = [self cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned long intLength = strlen(objPointer);
    int intCurrent;
    int i = 0, j = 0, k;
    
    unsigned char *objResult = (unsigned char *)calloc(intLength, sizeof(char));
    
    // Run through the whole string, converting as we go
    while ( ((intCurrent = *objPointer++) != '\0') && (intLength-- > 0) ) {
        if (intCurrent == '=') {
            if (*objPointer != '=' && ((i % 4) == 1)) {// || (intLength > 0)) {
                // the padding character is invalid at this point -- so this entire string is invalid
                free(objResult);
                return nil;
            }
            continue;
        }
        
        intCurrent = _base64DecodingTable[intCurrent];
        if (intCurrent == -1) {
            // we're at a whitespace -- simply skip over
            continue;
        } else if (intCurrent == -2) {
            // we're at an invalid character
            free(objResult);
            return nil;
        }
        
        switch (i % 4) {
            case 0:
                objResult[j] = intCurrent << 2;
                break;
                
            case 1:
                objResult[j++] |= intCurrent >> 4;
                objResult[j] = (intCurrent & 0x0f) << 4;
                break;
                
            case 2:
                objResult[j++] |= intCurrent >>2;
                objResult[j] = (intCurrent & 0x03) << 6;
                break;
                
            case 3:
                objResult[j++] |= intCurrent;
                break;
        }
        i++;
    }
    
    // mop things up if we ended on a boundary
    k = j;
    if (intCurrent == '=') {
        switch (i % 4) {
            case 1:
                // Invalid state
                free(objResult);
                return nil;
                
            case 2:
                k++;
                // flow through
            case 3:
                objResult[k] = 0;
        }
    }
    
    // Cleanup and setup the return NSData
    NSData * objData = [[[NSData alloc] initWithBytes:objResult length:j] autorelease];
    free(objResult);
    return [[[NSString alloc] initWithData:objData encoding:encoding] autorelease];
}

- (NSString *)MD5String {
    // Get the c string from the NSString
    const char *cString = [self UTF8String];
    unsigned char result[16];
    
    // MD5 encryption
    CC_MD5( cString, (int)strlen(cString), result );
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}

- (NSString *)MD5String16 {
    NSString *md5 = [self MD5String];
    if ([md5 length] == 32) {
        return [md5 substringWithRange:NSMakeRange(8, 16)];
    }
    return nil;
}

- (NSString*)escapeHTML {
	NSMutableString* s = [NSMutableString string];
	
	int start = 0;
	int len = (int)[self length];
	NSCharacterSet* chs = [NSCharacterSet characterSetWithCharactersInString:@"<>&\""];
	
	while (start < len) {
		NSRange r = [self rangeOfCharacterFromSet:chs options:0 range:NSMakeRange(start, len-start)];
		if (r.location == NSNotFound) {
			[s appendString:[self substringFromIndex:start]];
			break;
		}
		
		if (start < r.location) {
			[s appendString:[self substringWithRange:NSMakeRange(start, r.location-start)]];
		}
		
		switch ([self characterAtIndex:r.location]) {
			case '<':
				[s appendString:@"&lt;"];
				break;
			case '>':
				[s appendString:@"&gt;"];
				break;
			case '"':
				[s appendString:@"&quot;"];
				break;
			case '&':
				[s appendString:@"&amp;"];
				break;
		}
		
		start = (int)r.location + 1;
	}
	
	return s;
}

- (NSString*)unescapeHTML {
	NSMutableString* s = [NSMutableString string];
	NSMutableString* target = [[self mutableCopy] autorelease];
	NSCharacterSet* chs = [NSCharacterSet characterSetWithCharactersInString:@"&"];
	
	while ([target length] > 0) {
		NSRange r = [target rangeOfCharacterFromSet:chs];
		if (r.location == NSNotFound) {
			[s appendString:target];
			break;
		}
		
		if (r.location > 0) {
			[s appendString:[target substringToIndex:r.location]];
			[target deleteCharactersInRange:NSMakeRange(0, r.location)];
		}
		
		if ([target hasPrefix:@"&lt;"]) {
			[s appendString:@"<"];
			[target deleteCharactersInRange:NSMakeRange(0, 4)];
		} else if ([target hasPrefix:@"&gt;"]) {
			[s appendString:@">"];
			[target deleteCharactersInRange:NSMakeRange(0, 4)];
		} else if ([target hasPrefix:@"&quot;"]) {
			[s appendString:@"\""];
			[target deleteCharactersInRange:NSMakeRange(0, 6)];
		} else if ([target hasPrefix:@"&amp;"]) {
			[s appendString:@"&"];
			[target deleteCharactersInRange:NSMakeRange(0, 5)];
		} else {
			[s appendString:@"&"];
			[target deleteCharactersInRange:NSMakeRange(0, 1)];
		}
	}
	
	return s;
}

- (BOOL)isNumeric {
	const char *raw = (const char *) [self UTF8String];
	
	for (int i = 0; i < strlen(raw); i++) {
		if (raw[i] < '0' || raw[i] > '9') 
            return NO;
	}
	return YES;
}

- (NSString *)desEncryptWithKey:(NSString *)key {
//    const char *bytes = [self UTF8String];
//    int length  = strlen(bytes);
//
//    unsigned char buffer[1024];
//    memset(buffer, 0, sizeof(buffer));
//    size_t numBytesEncrypted = 0;
//    
//    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
//                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
//                                          [key UTF8String], 
//                                          kCCKeySizeDES,
//                                          NULL,
//                                          bytes, 
//                                          length,
//                                          buffer, 1024,
//                                          &numBytesEncrypted);
//    if (cryptStatus == kCCSuccess) {
//        NSString *res = [[NSString alloc] initWithBytes:buffer length:numBytesEncrypted encoding:NSASCIIStringEncoding];
//        DLog(@"%@", res);
//        return [res autorelease];
//    }
    return nil;
}

- (NSString *)desDecryptWithKey:(NSString *)key {
//    const char *bytes = [self UTF8String];
//    int length  = strlen(bytes);
//    
//    unsigned char buffer[1024];
//    memset(buffer, 0, sizeof(buffer));
//    size_t numBytesEncrypted = 0;
//    
//    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
//                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
//                                          [key UTF8String], 
//                                          kCCKeySizeDES,
//                                          NULL,
//                                          bytes, 
//                                          length,
//                                          buffer, 1024,
//                                          &numBytesEncrypted);
//    if (cryptStatus == kCCSuccess) {
//        NSString *res = [[NSString alloc] initWithBytes:buffer length:numBytesEncrypted encoding:NSASCIIStringEncoding];
//        DLog(@"%@", res);
//        return [res autorelease];
//    }
    return nil;
}

- (NSDictionary *)URLParams {
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"&?#"]];
    
    NSString *tempString = nil;
    NSString *mainUrl = nil;
    
    NSMutableDictionary *parsedParams = [[NSMutableDictionary alloc] init];
    
    [scanner scanUpToString:@"?" intoString:&mainUrl];
    if ([mainUrl isEqualToString:self]) {
        [scanner setScanLocation:0];
        [scanner scanUpToString:@"#" intoString:&mainUrl];
    } if ([mainUrl isEqualToString:self]) {
        //兼容 client_id=100222222&openid=801C07AC85537C5D33058C81FC1FB281 无url的解析
        [scanner setScanLocation:0];
    }
    
    while ([scanner scanUpToString:@"&" intoString:&tempString]) {
        NSArray *params = [tempString componentsSeparatedByString:@"="];
        if ([params count] == 2) {
            [parsedParams setValue:[params objectAtIndex:1] forKey:[params objectAtIndex:0]];
        }
    }
    
    DLog(@"%@", parsedParams);
    
    return [parsedParams autorelease];
}


@end
