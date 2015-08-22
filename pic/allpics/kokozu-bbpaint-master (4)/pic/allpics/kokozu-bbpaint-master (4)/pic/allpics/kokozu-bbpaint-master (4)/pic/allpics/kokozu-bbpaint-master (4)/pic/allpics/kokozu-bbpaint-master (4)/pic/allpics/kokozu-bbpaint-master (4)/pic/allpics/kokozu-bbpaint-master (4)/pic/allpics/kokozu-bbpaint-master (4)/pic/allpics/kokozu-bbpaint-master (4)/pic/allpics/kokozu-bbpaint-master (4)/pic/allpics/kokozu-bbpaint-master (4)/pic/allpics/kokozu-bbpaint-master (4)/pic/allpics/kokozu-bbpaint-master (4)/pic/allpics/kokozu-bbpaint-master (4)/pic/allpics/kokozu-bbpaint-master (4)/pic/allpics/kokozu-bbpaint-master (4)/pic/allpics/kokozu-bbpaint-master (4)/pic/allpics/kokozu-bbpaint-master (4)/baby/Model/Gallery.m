//
//  Gallery.m
//  baby
//
//  Created by zhang da on 14-2-5.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "Gallery.h"
#import "MemContainer.h"

@implementation Gallery

@dynamic _id;
@synthesize previousId;
@dynamic pictureCnt;
@dynamic userId;
@dynamic createTime;
@dynamic commentCnt;
@dynamic del;
@dynamic introVoice;
@dynamic introLength;
@dynamic likeCnt;

@synthesize liked;
@synthesize faved;


+ (NSDictionary *)mapping {
    static NSDictionary *map = nil;
    if (!map) {
        map = [@{
                @"_id": @"productionId",
                @"introLength": @"productionVoiceLength",
                @"introVoice": @"productionVoice",
                @"likeCnt": @"productionLike",
                @"createTime": @"productionTime",
                @"previousId": @"oldProductionId",
                @"faved": @"isShare"
                } retain];
    }
    return map;
}

+ (NSString *)primaryKey {
    return @"_id";
}

+ (Gallery *)getGalleryWithId:(long)_id {
    return (Gallery *)[[MemContainer me] getObject:[NSPredicate predicateWithFormat:@"_id = %ld", _id]
                                             clazz:[Gallery class]];
}

+ (NSArray *)getReGalleries:(long)galleryId {
    return [[MemContainer me] getObjects:[NSPredicate predicateWithFormat:@"previousId = %ld", galleryId]
                                   clazz:[Gallery class]];
}

@end
