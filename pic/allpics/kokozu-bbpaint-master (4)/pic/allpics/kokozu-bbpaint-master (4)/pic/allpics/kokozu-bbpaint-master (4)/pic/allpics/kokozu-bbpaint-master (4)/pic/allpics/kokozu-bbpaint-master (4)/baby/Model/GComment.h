//
//  GComment.h
//  baby
//
//  Created by zhang da on 14-3-18.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "Model.h"

@interface GComment : Model

@property (nonatomic, assign) long _id;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, assign) long long createTime;
@property (nonatomic, assign) long galleryId;
@property (nonatomic, assign) long userId;
@property (nonatomic, retain) NSString *voice;
@property (nonatomic, assign) int voiceLength;
@property (nonatomic, retain) NSString *replyTo;

+ (GComment *)getCommentWithId:(long)_id;
+ (NSArray *)getCommentsForGallery:(long)galleryId;

@end
