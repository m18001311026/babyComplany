//
//  AccountTask.m
//  baby
//
//  Created by zhang da on 14-3-2.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "UserTask.h"
#import "NSStringExtra.h"
#import "NSDictionaryExtra.h"
#import "NSDateExtra.h"
#import "Session.h"
#import "User.h"
#import "ConfManager.h"
#import "MemContainer.h"


@implementation UserTask

- (void)dealloc {
    [super dealloc];
}

- (id)initLogin:(NSString *)mobile password:(NSString *)password thirdId:(NSString *)thirdId {
    self = [super initWithUrl:[NSString stringWithFormat:@"%@/login/find.do", SERVERURL] method:GET];
    if (self) {
        [self addParameter:@"userNickname" value:mobile];
        [self addParameter:@"userPassword" value:[password MD5String]];
        if (thirdId) {
            [self addParameter:@"userOpenId" value:thirdId];
        }

        self.responseCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                NSDictionary *dict = (NSDictionary *)userInfo;
                NSDictionary *uDict = [dict objForKey:@"user"];
                if (uDict) {
                    [[MemContainer me] instanceFromDict:uDict clazz:[User class]];
                    
                    NSArray *loginList = [uDict objForKey:@"loginList"];
                    if (loginList) {
                        NSDictionary *sDict = [loginList objectAtIndex:0];
                        if (sDict) {
                            NSMutableDictionary *dict = [sDict mutableCopy];
                            [dict removeObjectForKey:@"users"];
                            Session *session = (Session *)[Session instanceFromDict:dict];
                            [dict release];
                            [[ConfManager me] setSession:session];
                        }
                    }
                }
                [self doLogicCallBack:YES info:nil];
            } else {
                [self doLogicCallBack:NO info:userInfo];
            }
        };
    }
    return self;
}

- (id)initUserDetail:(long)userId {
    self = [super initWithUrl:[NSString stringWithFormat:@"%@/user/find.do", SERVERURL]
                       method:GET
                      session:[[ConfManager me] getSession].session];
    if (self) {
        [self addParameter:@"userId" value:[NSString stringWithFormat:@"%ld", userId]];
        
        self.responseCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                NSDictionary *dict = (NSDictionary *)userInfo;
                NSDictionary *uDict = [dict objForKey:@"user"];
                if (uDict) {
                    //User *user = (User *)
                    [[MemContainer me] instanceFromDict:uDict clazz:[User class]];
                }
                [self doLogicCallBack:YES info:nil];
            } else {
                [self doLogicCallBack:NO info:userInfo];
            }
        };
    }
    return self;
}

- (id)initGetVerifiCode:(NSString *)mobile type:(int)type {
    self = [super initWithUrl:[NSString stringWithFormat:@"%@/register/verifiCodeQuery.do", SERVERURL] method:GET];
    if (self) {
        [self addParameter:@"userPhone" value:mobile];
        [self addParameter:@"type"
                     value:[NSString stringWithFormat:@"%@", type == 0? @"register_code": @"reset_password_code"]];
        
        self.responseCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                NSDictionary *dict = (NSDictionary *)userInfo;
                NSString *code = [dict stringForKey:@"code"];
                [self doLogicCallBack:YES info:code];
            } else {
                [self doLogicCallBack:NO info:userInfo];
            }
        };
    }
    return self;
}

- (id)initRegister:(NSString *)mobile
          nickname:(NSString *)name
          password:(NSString *)password
        verifiCode:(NSString *)code
           thirdId:(NSString *)thirdId {
    
    self = [super initWithUrl:[NSString stringWithFormat:@"%@/register/add.do", SERVERURL] method:GET];
    if (self) {
        if (thirdId) {
            [self addParameter:@"userOpenId" value:[password MD5String]];
        }
        [self addParameter:@"userNickname" value:name];
        [self addParameter:@"userPassword" value:[password MD5String]];
        [self addParameter:@"userPhone" value:mobile];
        [self addParameter:@"verifiCode" value:code];

        self.responseCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                NSDictionary *dict = (NSDictionary *)userInfo;
                [self doLogicCallBack:YES info:dict];
            } else {
                [self doLogicCallBack:NO info:userInfo];
            }
        };
    }
    return self;
}

//将用户老密码清空
- (id)initResetPassword:(NSString *)mobile verifiCode:(NSString *)code {
    self = [super initWithUrl:[NSString stringWithFormat:@"%@/register/findPassword.do", SERVERURL] method:GET];
    if (self) {
        [self addParameter:@"userPhone" value:mobile];
        [self addParameter:@"verifiCode" value:code];
        
        self.responseCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                NSDictionary *dict = (NSDictionary *)userInfo;
                NSDictionary *uDict = [dict objForKey:@"user"];
                if (uDict) {
                    [[MemContainer me] instanceFromDict:uDict clazz:[User class]];
                    
                    NSArray *loginList = [uDict objForKey:@"loginList"];
                    if (loginList) {
                        NSDictionary *sDict = [loginList objectAtIndex:0];
                        if (sDict) {
                            NSMutableDictionary *dict = [sDict mutableCopy];
                            [dict removeObjectForKey:@"users"];
                            Session *session = (Session *)[Session instanceFromDict:dict];
                            [dict release];
                            [[ConfManager me] setSession:session];
                        }
                    }
                }
                [self doLogicCallBack:YES info:nil];
            } else {
                [self doLogicCallBack:NO info:userInfo];
            }
        };
    }
    return self;
}

//修改密码
- (id)initSetPassword:(NSString *)password {
    self = [super initWithUrl:[NSString stringWithFormat:@"%@/user/rePassword.do", SERVERURL]
                       method:POST
                      session:[[ConfManager me] getSession].session];
    if (self) {
        [self addParameter:@"userPassword" value:[password MD5String]];
        
        self.responseCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                NSDictionary *dict = (NSDictionary *)userInfo;
                [self doLogicCallBack:YES info:dict];
            } else {
                [self doLogicCallBack:NO info:userInfo];
            }
        };
    }
    return self;
}

- (id)initEditIntro:(NSString *)intro
             avatar:(UIImage *)avatar
         background:(UIImage *)bg {
    
    self = [super initWithUrl:[NSString stringWithFormat:@"%@/user/update.do", SERVERURL]
                       method:POST
                      session:[[ConfManager me] getSession].session];
    if (self) {
        if (intro) {
            [self addParameter:@"userDescribe" value:intro];
        }
        if (avatar) {
            [self addParameter:@"userPhoto" value:UIImageJPEGRepresentation(avatar, 1.0) fileName:@"avatar.jpg"];
        }
        if (bg) {
            [self addParameter:@"userBackground" value:UIImageJPEGRepresentation(bg, 1.0) fileName:@"bg.jpg"];
        }
        self.responseCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                User *u = [User getUserWithId:[ConfManager me].userId];
                if (intro) {
                    u.userIntro = intro;
                }
                [self doLogicCallBack:YES info:nil];
            } else {
                [self doLogicCallBack:NO info:userInfo];
            }
        };
    }
    return self;
}

@end
