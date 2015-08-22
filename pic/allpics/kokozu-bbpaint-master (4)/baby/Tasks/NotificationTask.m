//
//  NotificationAtTask.m
//  baby
//
//  Created by zhang da on 14-6-16.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "NotificationTask.h"
#import "GComment.h"
#import "ConfManager.h"
#import "Session.h"
#import "User.h"
#import "Gallery.h"
#import "MemContainer.h"
#import "NSDictionaryExtra.h"


@implementation NotificationTask

- (id)initNotificationListAtPage:(int)page count:(int)count {
    self = [super initWithUrl:[NSString stringWithFormat:@"%@/user/findMessage.do", SERVERURL]
                       method:GET
                      session:[ConfManager me].sessionId];
    if (self) {
        [self addParameter:@"pageNow" value:[NSString stringWithFormat:@"%d", page]];
        [self addParameter:@"count" value:[NSString stringWithFormat:@"%d", count]];

        self.responseCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                NSDictionary *dict = (NSDictionary *)userInfo;
                
                NSMutableArray *commentIds = [[NSMutableArray alloc] init];
                NSArray *commentList = [dict objForKey:@"comment"];
                if ((NSNull *)commentList != [NSNull null]) {
                    for (NSDictionary *commDict in commentList) {
                        NSDictionary *userDict = [commDict objForKey:@"users"];
                        [[MemContainer me] instanceFromDict:userDict clazz:[User class]];
                        
                        GComment *comment = (GComment *)[[MemContainer me] instanceFromDict:commDict clazz:[GComment class]];
                        [commentIds addObject:@(comment._id)];
                    }
                }
                
                [self doLogicCallBack:YES info:[commentIds autorelease]];
            } else {
                [self doLogicCallBack:NO info:userInfo];
            }
        };
    }
    return self;
}

@end
