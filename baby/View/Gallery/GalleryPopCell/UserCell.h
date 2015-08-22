//
//  LessonCell.h
//  baby
//
//  Created by zhang da on 14-3-24.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageView;

@protocol UserCellDelegate <NSObject>

//- (void)relationEditTouched:(int)userId;

@end


@interface UserCell : UITableViewCell {
    ImageView *avatar;
    UILabel *title, *time, *moneyLable;
    UIButton *userBtn;
}

@property (nonatomic, assign) long userId;
@property (nonatomic, assign) id<UserCellDelegate> delegate;
@property (nonatomic, assign) bool isFriends;

- (void)updateLayout;

@end
