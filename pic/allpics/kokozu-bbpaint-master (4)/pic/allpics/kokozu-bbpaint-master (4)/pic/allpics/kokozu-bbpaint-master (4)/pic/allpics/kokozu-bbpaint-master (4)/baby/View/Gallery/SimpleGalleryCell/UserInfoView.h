//
//  UserVoiceInfoView.h
//  baby
//
//  Created by zhang da on 14-3-4.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageView;
@class UserInfoView;


@protocol UserInfoViewDelegate <NSObject>

@required
- (void)showUserDetail:(long)userId;
@end


@interface UserInfoView : UIView {
    ImageView *avatar;
    UILabel *userNameLabel, *timestampLabel;
}

@property (nonatomic, assign) long galleryId;
@property (nonatomic, assign) id<UserInfoViewDelegate> delegate;

- (void)updateLayout;

@end
