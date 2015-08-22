//
//  TOOL.h
//  baby
//
//  Created by zhang da on 14-3-31.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TOOL : NSObject

+ (NSString *)stringFromUnixTime:(long long)time;
//+ (NSString *)prettyStringFromUnixTime:(long long)time;
+ (NSString *)formattedStringFromDate:(NSDate *)date;

+ (NSString *)dateString:(NSDate *)time;
+ (NSString *)fullString:(NSDate *)time;
+ (NSString *)shortDateString:(NSDate *)time;
+ (NSString *)timeString:(NSDate *)time;

+ (NSString *)stringFromDate:(NSDate *)time format:(NSString *)format;

+ (NSDate *)dateFromUnixTime:(long long)time;

@end
