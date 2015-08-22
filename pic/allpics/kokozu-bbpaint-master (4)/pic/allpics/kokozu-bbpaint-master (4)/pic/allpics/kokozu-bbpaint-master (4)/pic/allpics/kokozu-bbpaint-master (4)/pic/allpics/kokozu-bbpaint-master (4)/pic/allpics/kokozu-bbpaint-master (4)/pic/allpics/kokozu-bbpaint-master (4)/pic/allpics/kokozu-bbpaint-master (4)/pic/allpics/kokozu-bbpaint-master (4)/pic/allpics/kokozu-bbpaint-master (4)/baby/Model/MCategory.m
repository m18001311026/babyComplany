//
//  Category.m
//  baby
//
//  Created by zhang da on 15/7/19.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import "MCategory.h"
#import "MemContainer.h"


@implementation MCategory

@dynamic _id;
@dynamic typeName;
@dynamic typePicture;

+ (NSDictionary *)mapping {
    static NSDictionary *map = nil;
    if (!map) {
        map = [@{
                 @"_id": @"typeId"
                 } retain];
    }
    return map;
}

+ (NSString *)primaryKey {
    return @"_id";
}

+ (MCategory *)getCategoryWithId:(long)_id {
    return (MCategory *)[[MemContainer me] getObject:[NSPredicate predicateWithFormat:@"_id = %ld", _id]
                                               clazz:[MCategory class]];
}


@end
