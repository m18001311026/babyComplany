//
//  NSDictionaryExtra.m
//  phonebook
//
//  Created by kokozu on 10-12-18.
//  Copyright 2010 公司. All rights reserved.
//

#import "NSDictionaryExtra.h"

@implementation NSDictionary (Extra)

- (id)objForKey:(id)aKey {
    if (aKey) {
        if ( (id)self!=[NSNull null] 
            && [self objectForKey:aKey] 
            && [self objectForKey:aKey]!=[NSNull null])
            return [self objectForKey:aKey];
    }
    return nil;
}

- (NSString *)stringForKey:(id)aKey {
    if (aKey) {
        if ( (id)self!=[NSNull null]
            && [self objectForKey:aKey]
            && [self objectForKey:aKey]!=[NSNull null])
            return [NSString stringWithFormat:@"%@", [self objectForKey:aKey]];
    }
    return nil;
}

- (NSNumber *)intNumberForKey:(id)aKey {
    if (aKey) {
        if ( (id)self!=[NSNull null]
            && [self objectForKey:aKey]
            && [self objectForKey:aKey]!=[NSNull null]) {
            
            int value = [[self objectForKey:aKey] intValue];
            return [NSNumber numberWithInt:value];
        }
    }
    return nil;
}

- (int)intForKey:(id)aKey {
    if (aKey) {
        if ( (id)self!=[NSNull null]
            && [self objectForKey:aKey]
            && [self objectForKey:aKey]!=[NSNull null]) {
            
            return [[self objectForKey:aKey] intValue];
        }
    }
    return 0;
}

- (NSNumber *)floatNumberForKey:(id)aKey {
    if (aKey) {
        if ( (id)self!=[NSNull null]
            && [self objectForKey:aKey]
            && [self objectForKey:aKey]!=[NSNull null]) {
            
            float value = [[self objectForKey:aKey] floatValue];
            return [NSNumber numberWithFloat:value];
        }
    }
    return nil;
}

- (NSNumber *)boolNumberForKey:(id)aKey {
    if (aKey) {
        if ( (id)self!=[NSNull null]
            && [self objectForKey:aKey]
            && [self objectForKey:aKey]!=[NSNull null]) {
            
            BOOL value = [[self objectForKey:aKey] boolValue];
            return [NSNumber numberWithBool:value];
        }
    }
    return nil;
}

- (NSDate *)dateForKey:(id)aKey withFormat:(NSString *)format {
    NSString *timeStr = [self stringForKey:aKey];
    if (timeStr) {
//        return [[DateEngine sharedDateEngine] dateFromString:timeStr withFormat:format];
    }
    return nil;
}

@end
