//
//  Session.m
//  baby
//
//  Created by zhang da on 14-3-2.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "Session.h"

@implementation Session

@dynamic loginTime, expireTime, session, loginIp, userId;

- (long long)unixTimestamp:(NSDate *)date {
    NSTimeInterval time = [date timeIntervalSince1970]*1000;
    long long timestamp = [[NSNumber numberWithDouble:time] longLongValue];
    return timestamp;
}

- (bool)expired {
    return NO;//(long)([self unixTimestamp:[NSDate date]] - self.expireTime) > 0l;
}

@end
