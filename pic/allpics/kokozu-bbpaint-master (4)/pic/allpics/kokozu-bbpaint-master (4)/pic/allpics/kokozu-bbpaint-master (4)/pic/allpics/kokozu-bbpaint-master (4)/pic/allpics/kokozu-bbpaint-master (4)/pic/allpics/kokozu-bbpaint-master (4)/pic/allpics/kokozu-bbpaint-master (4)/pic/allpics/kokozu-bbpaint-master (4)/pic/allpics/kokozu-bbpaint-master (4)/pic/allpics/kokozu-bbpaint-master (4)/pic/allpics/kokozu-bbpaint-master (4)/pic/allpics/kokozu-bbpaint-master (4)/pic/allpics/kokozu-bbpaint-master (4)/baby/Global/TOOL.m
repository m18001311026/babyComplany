//
//  TOOL.m
//  baby
//
//  Created by zhang da on 14-3-31.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "TOOL.h"

@implementation TOOL

static NSDateFormatter *formatter = nil;

+ (NSDateFormatter *)formatter {
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
    }
    return formatter;
}

+ (NSString *)stringFromUnixTime:(long long)time {
    NSDateFormatter *f = [self formatter];
    [f setDateFormat:@"yy-MM-dd"];
    return [f stringFromDate:[NSDate dateWithTimeIntervalSince1970:time/1000]];
}

//+ (NSString *)prettyStringFromUnixTime:(long long)time {
//    NSDateFormatter *f = [self formatter];
//    [f setDateFormat:@"M月d日 hh:mm"];
//    return [f stringFromDate:[NSDate dateWithTimeIntervalSince1970:time/1000]];
//}

+ (NSDate *)dateFromUnixTime:(long long)time {
    NSDateFormatter *f = [self formatter];
    [f setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    return [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)time/1000];
}

+ (NSString *)dateString:(NSDate *)time {
    NSDateFormatter *f = [self formatter];
    [f setDateFormat:@"yy-MM-dd"];
    return [f stringFromDate:time];
}

+ (NSString *)fullString:(NSDate *)time {
    NSDateFormatter *f = [self formatter];
    [f setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    return [f stringFromDate:time];
}

+ (NSString *)shortDateString:(NSDate *)time {
    NSDateFormatter *f = [self formatter];
    [f setDateFormat:@"M-d"];
    return [f stringFromDate:time];
}

+ (NSString *)timeString:(NSDate *)time {
    NSDateFormatter *f = [self formatter];
    [f setDateFormat:@"hh:mm:ss"];
    return [f stringFromDate:time];
}

+ (NSString *)stringFromDate:(NSDate *)time format:(NSString *)format {
    NSDateFormatter *f = [self formatter];
    [f setDateFormat:format];
    return [f stringFromDate:time];
}

+ (NSString *)formattedStringFromDate_bak:(NSDate *)date {
	if (!date) return @"";
	
	NSTimeInterval timeInterval = [date timeIntervalSinceNow];
	int minute = (int)fabs(timeInterval / 60);
	
    //NSLog(@"now:%@ -- date:%@ -- timeinterval1:%f -- timeinterval2:%f", [NSDate date], date, timeInterval, [date timeIntervalSinceDate:[NSDate date]]);
    
	if (minute < 60) {
        if (minute <1) return @"刚刚";
        
		return [NSString stringWithFormat:@"%d 分钟前", (minute<=1? 1: minute)];
	} else {
        int hour = (int)(minute / 60);
        if (hour < 24) {
            return [NSString stringWithFormat:@"%d 小时前", (hour<=1? 1: hour)];
        } else {
            int day = (int)(hour / 24);
            if (day < 7) {
                return [NSString stringWithFormat:@"%d 天前", (day<=1? 1: day)];
            } else if ( day >= 7 && day < 30) {
                int week = (int)(day / 7);
                return [NSString stringWithFormat:@"%d 周前", (week<=1? 1: week)];
            } else {
                int month = (int)(day / 30);
                if (month < 12) {
                    return [NSString stringWithFormat:@"%d 月前", (month<=1? 1: month)];
                } else {
                    int year = (int)(month / 12);
                    return [NSString stringWithFormat:@"%d 年前", (year<=1? 1: year)];
                }
            }
        }
    }
}

+ (NSString *)formattedStringFromDate:(NSDate *)date {
    NSDate *now = [NSDate date];
    NSString *datePara = [self shortDateString:date];
    NSString *dateNow = [self shortDateString:now];
    if ([datePara isEqualToString:dateNow]) {
        NSDateFormatter *f = [self formatter];
        [f setDateFormat:@"hh:mm"];
        return [f stringFromDate:date];
    } else {
        NSDateFormatter *f = [self formatter];
        [f setDateFormat:@"yy年"];
        NSString *yearPara = [f stringFromDate:date];
        NSString *yearNow = [f stringFromDate:now];
        if ([yearPara isEqualToString:yearNow]) {
            return datePara;
        } else {
            return yearPara;
        }
    }
}



@end
