//
//  AccountTask.h
//  baby
//
//  Created by zhang da on 14-3-2.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "BBNetworkTask.h"

@interface UserTask : BBNetworkTask

- (id)initLogin:(NSString *)mobile password:(NSString *)password thirdId:(NSString *)thirdId;

/*
 type 0注册 1重置密码
 */
- (id)initGetVerifiCode:(NSString *)mobile type:(int)type;

- (id)initRegister:(NSString *)mobile
          nickname:(NSString *)name
          password:(NSString *)password
        verifiCode:(NSString *)code
           thirdId:(NSString *)thirdId;

//将用户老密码清空
- (id)initResetPassword:(NSString *)mobile verifiCode:(NSString *)code;

//修改密码
- (id)initSetPassword:(NSString *)password;

- (id)initUserDetail:(long)userId;

- (id)initEditIntro:(NSString *)intro
             avatar:(UIImage *)avatar
         background:(UIImage *)bg;

@end
