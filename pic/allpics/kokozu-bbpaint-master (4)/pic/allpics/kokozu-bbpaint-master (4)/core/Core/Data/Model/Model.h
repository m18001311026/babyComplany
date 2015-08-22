//
//  Model.h
//  baby
//
//  Created by zhang da on 14-2-4.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_KEY @"orm.default"

typedef enum {
    Replace = 0,
    Merge
} UpdateType;

@interface Model : NSObject

+ (NSDictionary *)mapping;
+ (NSString *)primaryKey;

+ (Model *)instanceFromDict:(NSDictionary *)dict;
+ (NSPredicate *)predictForProperty:(NSString *)propertyName value:(id)value;

- (id)initWithDict:(NSDictionary *)dict;
- (void)updateFromDict:(NSDictionary *)dict updateType:(UpdateType)type;
- (NSDictionary *)exportData;

@end
