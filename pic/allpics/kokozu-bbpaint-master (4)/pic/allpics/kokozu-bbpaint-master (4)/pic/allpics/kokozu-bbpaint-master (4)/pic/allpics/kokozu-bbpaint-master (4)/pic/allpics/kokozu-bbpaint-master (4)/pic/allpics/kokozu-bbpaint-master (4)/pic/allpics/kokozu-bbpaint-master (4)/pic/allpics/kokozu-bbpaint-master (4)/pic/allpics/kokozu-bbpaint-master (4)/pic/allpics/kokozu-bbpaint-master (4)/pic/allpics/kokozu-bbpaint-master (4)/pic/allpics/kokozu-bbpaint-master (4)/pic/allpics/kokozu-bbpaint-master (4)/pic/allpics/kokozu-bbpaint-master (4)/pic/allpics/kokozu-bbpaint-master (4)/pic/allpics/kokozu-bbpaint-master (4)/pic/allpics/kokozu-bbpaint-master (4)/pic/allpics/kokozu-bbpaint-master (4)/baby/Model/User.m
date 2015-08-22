//
//  User.m
//  baby
//
//  Created by zhang da on 14-2-4.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "User.h"
#import "MemContainer.h"


@implementation User

@dynamic _id;
@dynamic userPhone;
@dynamic userNickname;
@dynamic userIntro;
@dynamic userPhoto;
@dynamic userBackground;
@dynamic userCreateTime;

@dynamic productionList;

+ (NSString *)primaryKey {
    return @"_id";
}

+ (NSDictionary *)mapping {
    static NSDictionary *map = nil;
    if (!map) {
        map = [@{
                @"_id": @"userId",
                @"userIntro": @"userDescribe"
                } retain];
    }
    return map;
}

+ (User *)getUserWithId:(long)_id {
    return (User *)[[MemContainer me] getObject:[NSPredicate predicateWithFormat:@"_id = %ld", _id]
                                          clazz:[User class]];
}

@end
