//
//  Gallery.h
//  baby
//
//  Created by zhang da on 14-2-5.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "Model.h"

@interface Gallery : Model

@property (nonatomic, assign) long _id;
@property (nonatomic, assign) long previousId;

@property (nonatomic, assign) int pictureCnt;
@property (nonatomic, assign) long userId;
@property (nonatomic, assign) long commentCnt;
@property (nonatomic, assign) long likeCnt;
@property (nonatomic, assign) bool del;
@property (nonatomic, assign) long long createTime;

@property (nonatomic, retain) NSString *introVoice;
@property (nonatomic, assign) int introLength;

@property (nonatomic, retain) NSNumber *liked;
@property (nonatomic, assign) bool faved;

+ (Gallery *)getGalleryWithId:(long)_id;
+ (NSArray *)getReGalleries:(long)galleryId;

@end
