//
//  VoiceTask.m
//  baby
//
//  Created by zhang da on 14-3-17.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "VoiceTask.h"

@implementation VoiceTask

- (id)initGetVoice:(NSString *)url {
    self = [super initWithUrl:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] method:GET];
    if (self) {
        self.rawData = YES;
        self.responseCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:userInfo, @"voice", url, @"url", nil];
                [self doLogicCallBack:YES info:dict];
            } else {
                [self doLogicCallBack:NO info:userInfo];
            }
        };
    }
    return self;
}

@end
