//
//  GalleryTask.h
//  baby
//
//  Created by zhang da on 14-3-16.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "BBNetworkTask.h"

@interface GalleryTask : BBNetworkTask

//首页列表
- (id)initGalleryList:(bool)classic page:(int)page count:(int)count;

//获取转发的列表
- (id)initReGalleryList:(long)galleryId page:(int)page count:(int)count;

//获取用户图集列表
- (id)initUserGalleryList:(long)userId page:(int)page count:(int)count;

//获取收藏图集列表
- (id)initLikeGalleryListAtPage:(int)page count:(int)count;

//图集详情
- (id)initGalleryDetail:(long)galleryId;

//删除图集
- (id)initDeleteGallery:(long)galleryId;

//获取评论列表
- (id)initGCommentList:(long)galleryId page:(int)page count:(int)count;

//删除评论
- (id)initDeleteComment:(long)commentId;

//赞或不赞
- (id)initLikeGallery:(long)galleryId relation:(bool)relation;

//收藏或不收藏
- (id)initFavGallery:(long)galleryId relation:(bool)relation;

@end
