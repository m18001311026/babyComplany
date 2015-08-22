//
//  Material.m
//  baby
//
//  Created by zhang da on 15/7/19.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import "Material.h"
#import "MemContainer.h"


@implementation Material

@dynamic _id;
@dynamic categoryId;
@dynamic fodderPicture;

+ (NSDictionary *)mapping {
    static NSDictionary *map = nil;
    if (!map) {
        map = [@{
                 @"_id": @"fodderId",
                 @"categoryId": @"typeId"
                 } retain];
    }
    return map;
}

+ (NSString *)primaryKey {
    return @"_id";
}

+ (Material *)getMaterialWithId:(long)_id {
    return (Material *)[[MemContainer me] getObject:[NSPredicate predicateWithFormat:@"_id = %ld", _id]
                                              clazz:[Material class]];
}

+ (NSArray *)getMaterialsForCategory:(long)categoryId {
    return [[MemContainer me] getObjects:[NSPredicate predicateWithFormat:@"categoryId = %ld", categoryId]
                                   clazz:[Material class]];
}

@end
