//
//  UserInfoView.m
//  baby
//
//  Created by zhang da on 14-3-4.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "UserInfoView.h"
#import "User.h"
#import "Gallery.h"
#import "ImageView.h"

@interface UserInfoView ()

@property (nonatomic, retain) User *user;
@property (nonatomic, retain) Gallery *gallery;

@end


@implementation UserInfoView

- (void)dealloc {
    self.user = nil;
    self.delegate = nil;
    
    [super dealloc];
}

- (void)setGalleryId:(long)galleryId {
    if (_galleryId != galleryId) {
        _galleryId = galleryId;
        self.gallery = [Gallery getGalleryWithId:galleryId];
        self.user = [User getUserWithId:self.gallery.userId];
    } else if ((!self.gallery || !self.user) && _galleryId > 0) {
        self.gallery = [Gallery getGalleryWithId:galleryId];
        self.user = [User getUserWithId:self.gallery.userId];
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView *bg = [[UIImageView alloc] init];
        bg.frame = CGRectMake(10, 2, 130, 50);
        bg.backgroundColor=[UIColor colorWithRed:190/255.0 green: 190/255.0 blue:190/255.0 alpha:0.8];
        bg.layer.cornerRadius = 8;
        bg.layer.masksToBounds = YES;
        [self addSubview:bg];
        [bg release];
        
        avatar = [[ImageView alloc] initWithImage:[UIImage imageNamed:@"baby_logo.png"]];
        avatar.frame = CGRectMake(14, 6, 42, 42);
        avatar.layer.cornerRadius = 21;
        avatar.layer.borderColor = [UIColor whiteColor].CGColor;
        avatar.layer.borderWidth = 2;
        avatar.layer.masksToBounds = YES;
        [self addSubview:avatar];
        [avatar release];
        
        userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 80, 16)];
        userNameLabel.backgroundColor = [UIColor clearColor];
        userNameLabel.font = [UIFont systemFontOfSize:14];
        userNameLabel.textColor = [UIColor whiteColor];
        [self addSubview:userNameLabel];
        [userNameLabel release];
        
        timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 32, 80, 14)];
        timestampLabel.backgroundColor = [UIColor clearColor];
        timestampLabel.minimumFontSize = 10.0f;
        timestampLabel.numberOfLines = 1;
        timestampLabel.font = [UIFont systemFontOfSize:12];
        timestampLabel.textColor = [UIColor whiteColor];
        [self addSubview:timestampLabel];
        [timestampLabel release];

        UIButton *avatarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        avatarBtn.frame = avatar.frame;
        [avatarBtn addTarget:self action:@selector(avatarTouched) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:avatarBtn];
    }
    return self;
}

- (void)updateLayout {
    avatar.imagePath = self.user.userPhoto;
    userNameLabel.text = self.user.userNickname;
    timestampLabel.text = [TOOL formattedStringFromDate:[TOOL dateFromUnixTime:self.gallery.createTime]];
}

- (void)avatarTouched {
    if (self.delegate) {
        [self.delegate showUserDetail:self.user._id];
    }
}


@end
