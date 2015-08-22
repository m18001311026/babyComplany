//
//  NSDate_NSDateExtra.h
//  baby
//
//  Created by zhang da on 14-3-2.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

@implementation NSDate (Extra)

- (NSString *)fullString {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    return [[format autorelease] stringFromDate:self];
}

- (NSString *)dateString {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    return [[format autorelease] stringFromDate:self];
}

- (NSString *)timeString {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"hh:mm:ss"];
    return [[format autorelease] stringFromDate:self];
}

@end
