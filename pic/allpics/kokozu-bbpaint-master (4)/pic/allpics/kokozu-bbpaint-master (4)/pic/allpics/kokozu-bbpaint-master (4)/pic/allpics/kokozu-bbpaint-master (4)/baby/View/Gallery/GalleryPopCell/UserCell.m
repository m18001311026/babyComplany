//
//  UserCell.m
//  baby
//
//  Created by zhang da on 14-3-24.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "UserCell.h"
#import "ImageView.h"
#import "UIColorExtra.h"
#import "User.h"

#import "UserTask.h"
#import "TaskQueue.h"
#import "Session.h"


@implementation UserCell

- (void)dealloc {
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        avatar = [[ImageView alloc] initWithFrame:CGRectMake(10, 10, 54, 54)];
        avatar.clipsToBounds = YES;
        avatar.layer.cornerRadius = 27;
        avatar.layer.borderColor = [Shared bbGray].CGColor;
        avatar.layer.borderWidth = 2;
        [self addSubview:avatar];
        [avatar release];
        
        title = [[UILabel alloc] initWithFrame:CGRectMake(74, 29, 140, 16)];
        title.text = @"";
        title.font = [UIFont systemFontOfSize:14];
        title.textColor = [UIColor darkGrayColor];
        title.backgroundColor = [UIColor clearColor];
        [self addSubview:title];
        [title release];
        
//        userBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        userBtn.frame = CGRectMake(240, 24, 70, 26);
//        userBtn.backgroundColor = [Shared bbGray];
//        [userBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [userBtn addTarget:self action:@selector(editRelation) forControlEvents:UIControlEventTouchUpInside];
//        userBtn.titleLabel.font = [UIFont systemFontOfSize:12];
//        userBtn.layer.cornerRadius = 2.0;
//        userBtn.layer.masksToBounds = YES;
//        userBtn.titleLabel.textAlignment = UITextAlignmentCenter;
//        [self addSubview:userBtn];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateLayout {
    User *user = [User getUserWithId:self.userId];
    
    avatar.imagePath = user.userPhoto;
    title.text = user.userNickname;

//
//    if (self.isFriends) {
//        [userBtn setTitle:@"取消关注" forState:UIControlStateNormal];
//    } else {
//        [self loadRelation];
//    }
}

- (void)loadRelation {
    CallbackBlock block = ^(bool successful, id userInfo) {
        if (successful) {
            User *user = [User getUserWithId:self.userId];
            if (user) {
//                if (!user.following) {
//                    UserTask *task = [[UserTask alloc] initUserDetail:self.userId];
//                    task.logicCallbackBlock = ^(bool successful, id userInfo) {
//                        if (user.following) {
//                            [userBtn setTitle:[user.following boolValue]? @"取消关注": @"+关注"
//                                     forState:UIControlStateNormal];
//                        }
//                    };
//                    [TaskQueue addTaskToQueue:task];
//                    [task release];
//                } else if (user.following) {
//                    [userBtn setTitle:[user.following boolValue]? @"取消关注": @"+关注"
//                             forState:UIControlStateNormal];
//                }
            }
        }
    };
    
    User *user = [User getUserWithId:self.userId];
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

- (void)editRelation {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(relationEditTouched:)]) {
//        [self.delegate relationEditTouched:self.userId];
//    }
}

@end
