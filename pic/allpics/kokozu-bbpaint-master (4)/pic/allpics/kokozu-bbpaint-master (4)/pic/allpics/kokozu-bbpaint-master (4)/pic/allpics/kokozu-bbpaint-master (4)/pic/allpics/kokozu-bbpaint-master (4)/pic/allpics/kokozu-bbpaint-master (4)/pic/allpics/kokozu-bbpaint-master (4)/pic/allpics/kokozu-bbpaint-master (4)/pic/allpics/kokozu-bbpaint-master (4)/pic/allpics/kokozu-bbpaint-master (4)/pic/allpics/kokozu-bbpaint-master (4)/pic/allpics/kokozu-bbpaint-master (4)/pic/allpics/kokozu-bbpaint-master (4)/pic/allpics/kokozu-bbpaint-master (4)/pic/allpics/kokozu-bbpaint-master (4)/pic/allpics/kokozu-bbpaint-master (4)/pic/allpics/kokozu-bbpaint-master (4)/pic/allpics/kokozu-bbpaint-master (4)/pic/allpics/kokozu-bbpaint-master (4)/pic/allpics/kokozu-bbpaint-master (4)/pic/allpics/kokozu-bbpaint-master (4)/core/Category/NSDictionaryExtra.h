//
//  NSDictionaryExtra.h
//  phonebook
//
//  Created by kokozu on 10-12-18.
//  Copyright 2010 公司. All rights reserved.
//

@interface NSDictionary (Extra) 

- (id)objForKey:(id)aKey;
- (NSString *)stringForKey:(id)aKey;
- (NSNumber *)intNumberForKey:(id)aKey;
- (int)intForKey:(id)aKey;
- (NSNumber *)floatNumberForKey:(id)aKey;
- (NSNumber *)boolNumberForKey:(id)aKey;
- (NSDate *)dateForKey:(id)aKey withFormat:(NSString *)format;

@end
