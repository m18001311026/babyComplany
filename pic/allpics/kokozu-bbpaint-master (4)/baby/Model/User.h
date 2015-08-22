//
//  User.h
//  baby
//
//  Created by zhang da on 14-2-4.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "Model.h"

@interface User : Model


@property (nonatomic, assign) long _id;
@property (nonatomic, retain) NSString *userPhone;
@property (nonatomic, retain) NSString *userNickname;
@property (nonatomic, retain) NSString *userIntro;
@property (nonatomic, assign) long long userCreateTime;

@property (nonatomic, retain) NSString *userPhoto;
@property (nonatomic, retain) NSString *userBackground;

@property (nonatomic, assign) long productionList;


+ (User *)getUserWithId:(long)_id;

@end
