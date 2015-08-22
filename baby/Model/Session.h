//
//  Session.h
//  baby
//
//  Created by zhang da on 14-3-2.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "Model.h"

@interface Session : Model

@property (nonatomic, assign) long long loginTime;
@property (nonatomic, assign) long long expireTime;
@property (nonatomic, retain) NSString *session;
@property (nonatomic, retain) NSString *loginIp;
@property (nonatomic, assign) long userId;

- (bool)expired;

@end
