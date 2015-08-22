//
//  GalleryCell.h
//  baby
//
//  Created by zhang da on 14-3-4.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfoView.h"
#import "ReView.h"
#import "CommentView.h"


@protocol SimpleGalleryCellDelegate <NSObject>
@required
- (void)reGallery:(long)galleryId;
- (void)shareGallery:(long)galleryId;
@optional
- (void)tappedAtImage:(long)galleryId;
@end


@class UIImageButton;
@class ImageView;

@interface SimpleGalleryCell : UITableViewCell <UIScrollViewDelegate, UIAlertViewDelegate> {
    
    UIScrollView *galleryHolder;
    NSMutableArray *pictureViews;
    NSMutableArray *pictures;
    UIPageControl *paging;

    UserInfoView *user;
    UIImageButton *likeBtn, *commentBtn, *favBtn, *reBtn, *shareBtn;
    UIImageButton *deleteBtn;
    
    ReView *reView;
    UITextField *likeDetailLabel;
    CommentView *commentView;
    
}

@property (nonatomic, assign) id<SimpleGalleryCellDelegate> delegate;
@property (nonatomic, assign) long galleryId;
@property (nonatomic, assign) bool isPlaying;

@property (nonatomic, assign) id<UserInfoViewDelegate, CommentViewDelegate, ReViewDelegate> funcDelegate;

- (void)updateLayout;
+ (float)cellHeight:(long)galleryId;

@end
