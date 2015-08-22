//
//  FeedbackTask.m
//  baby
//
//  Created by zhang da on 14-6-13.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "FeedbackTask.h"
#import "ConfManager.h"
#import "Session.h"

@implementation FeedbackTask

- (id)initFeedback:(NSString *)content {
    self = [super initWithUrl:SERVERURL method:POST session:[[ConfManager me] getSession].session];
    if (self) {
        [self addParameter:@"action" value:@"feedback_Add"];
        [self addParameter:@"content" value:content];
        
        self.responseCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                [self doLogicCallBack:YES info:nil];
            } else {
                [self doLogicCallBack:NO info:userInfo];
            }
        };
    }
    return self;
}

@end
