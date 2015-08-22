//
//  Picture.m
//  baby
//
//  Created by zhang da on 14-3-9.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "Picture.h"
#import "MemContainer.h"

@implementation Picture

@dynamic _id, galleryId, sort, imageSmall, imageMid, imageBig, userId, createTime;

- (void)dealloc {
    self.localImage = nil;
    self.localVoice = nil;
    
    [super dealloc];
}

+ (NSString *)primaryKey {
    return @"_id";
}

+ (NSDictionary *)mapping {
    static NSDictionary *map = nil;
    if (!map) {
        map = [@{
                 @"_id": @"pictureId",
                 @"galleryId": @"productionId",
                 @"sort": @"pictureOrder"
                 } retain];
    }
    return map;
}

+ (Picture *)getPictureWithId:(long)_id {
    return (Picture *)[[MemContainer me] getObject:[NSPredicate predicateWithFormat:@"_id = %ld", _id]
                                             clazz:[Picture class]];
}

+ (NSArray *)getPicturesForGallery:(long)galleryId {
    return [[MemContainer me] getObjects:[NSPredicate predicateWithFormat:@"galleryId = %ld", galleryId]
                                   clazz:[Picture class]];
}

+ (NSString *)coverForGallery:(long)galleryId {
    NSArray *pics = [Picture getPicturesForGallery:galleryId];
    if (pics.count) {
        Picture *p = (Picture *)[pics objectAtIndex:0];
        return p.imageBig;
    }
    return nil;
}


@end
