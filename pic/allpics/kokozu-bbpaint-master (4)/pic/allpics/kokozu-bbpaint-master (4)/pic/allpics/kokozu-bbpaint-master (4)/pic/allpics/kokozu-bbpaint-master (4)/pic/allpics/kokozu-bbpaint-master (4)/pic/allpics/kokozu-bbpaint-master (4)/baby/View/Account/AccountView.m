//
//  AccountView.m
//  baby
//
//  Created by zhang da on 14-3-6.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "AccountView.h"
#import "ImageView.h"
#import "User.h"

#import "UserTask.h"
#import "TaskQueue.h"
#import "ConfManager.h"
#import "Session.h"

@implementation AccountView

- (void)dealloc {

    [super dealloc];
}


- (id)initWithFrame:(CGRect)frame forUser:(long)userId {
    self = [super initWithFrame:frame];
    if (self) {
        self.userId = userId;
        
        userBg = [[ImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 219)];
        userBg.contentMode = UIViewContentModeScaleAspectFill;
        userBg.userInteractionEnabled = YES;
        [self addSubview:userBg];
        [userBg release];
        
        avatar = [[ImageView alloc] initWithFrame:CGRectMake(130, 67, 60, 60)];
        avatar.layer.cornerRadius = 30;
        avatar.layer.borderColor = [UIColor whiteColor].CGColor;
        avatar.layer.borderWidth = 2;
        avatar.layer.masksToBounds = YES;
        avatar.userInteractionEnabled = YES;
        [self addSubview:avatar];
        [avatar release];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 135, 300, 20)];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.shadowColor = [UIColor grayColor];
        nameLabel.shadowOffset = CGSizeMake(0, 1);
        nameLabel.textAlignment = UITextAlignmentCenter;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont systemFontOfSize:18];
        nameLabel.text = @"";
        [self addSubview:nameLabel];
        [nameLabel release];
        
        introLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 158, 280, 16)];
        introLabel.textColor = [UIColor whiteColor];
        introLabel.shadowColor = [UIColor grayColor];
        introLabel.shadowOffset = CGSizeMake(0, 1);
        introLabel.textAlignment = UITextAlignmentCenter;
        introLabel.backgroundColor = [UIColor clearColor];
        introLabel.font = [UIFont systemFontOfSize:13];
        introLabel.text = @"";
        [self addSubview:introLabel];
        [introLabel release];
        
        if ([ConfManager me].userId == userId) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(homeTapped)];
            tap.cancelsTouchesInView = NO;
            [userBg addGestureRecognizer:tap];
            [tap release];
            
            UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(avatarTapped)];
            avatarTap.cancelsTouchesInView = NO;
            [avatar addGestureRecognizer:avatarTap];
            [avatarTap release];
            
            userBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            userBtn.frame = CGRectMake(196, 87, 70, 20);
            [userBtn setTitle:@"编辑" forState:UIControlStateNormal];
            [userBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [userBtn setBackgroundColor:[UIColor darkGrayColor]];
            [userBtn addTarget:self action:@selector(userBtnTouched) forControlEvents:UIControlEventTouchUpInside];
            userBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
            [userBtn.layer setCornerRadius:10];
            [self addSubview:userBtn];
        }
    }
    return self;
}

- (void)updateLayout {
    User *user = [User getUserWithId:self.userId];
    
    CallbackBlock block = ^(bool successful, id userInfo) {
        if (successful) {
            User *user = [User getUserWithId:self.userId];
            if (user) {
                avatar.imagePath = user.userPhoto;
                if (user.userBackground) {
                    userBg.imagePath = user.userBackground;
                }
                nameLabel.text = user.userNickname;
                introLabel.text = user.userIntro;
            }
        }
    };

    if (user) {
        block(YES, nil);
    } else {
        UserTask *task = [[UserTask alloc] initUserDetail:self.userId];
        task.logicCallbackBlock = ^(bool successful, id userInfo) {
            block(YES, nil);
        };
        [TaskQueue addTaskToQueue:task];
        [task release];
    }
    
}

- (void)setBgImage:(UIImage *)image {
    userBg.image = image;
}

- (void)setAvatarImage:(UIImage *)image {
    avatar.image = image;
}

- (void)avatarTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editUserAvatar)]) {
        [self.delegate editUserAvatar];
    }
}

- (void)homeTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editUserHome)]) {
        [self.delegate editUserHome];
    }
}

- (void)userBtnTouched {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editUserDetail)]) {
        [self.delegate editUserDetail];
    }
}


@end
