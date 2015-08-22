//
//  ShareTask.m
//  baby
//
//  Created by zhang da on 14-6-19.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "ShareTask.h"
#import "User.h"
#import "MemContainer.h"
#import "ConfManager.h"
#import "Session.h"


@implementation ShareTask

- (id)initContactMatch:(NSString *)contacts {
    self = [super initWithUrl:SERVERURL method:POST session:[[ConfManager me] getSession].session];
    if (self) {
        [self addParameter:@"action" value:@"user_Search"];
        [self addParameter:@"mobiles" value:contacts];

        self.responseCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                NSDictionary *dict = (NSDictionary *)userInfo;
                NSArray *users = [dict objectForKey:@"users"];
                
                if (users && users.count > 0) {
                    NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
                    
                    for (NSDictionary *userDict in users) {
                        //User *user = (User *)
                        [[MemContainer me] instanceFromDict:userDict clazz:[User class]];
                        //[map setValue:@(user._id) forKey:user.name];
                    }
                    [self doLogicCallBack:YES info:[map autorelease]];
                } else {
                    [self doLogicCallBack:YES info:nil];
                }
            } else {
                [self doLogicCallBack:NO info:userInfo];
            }
        };
    }
    return self;

}


@end
