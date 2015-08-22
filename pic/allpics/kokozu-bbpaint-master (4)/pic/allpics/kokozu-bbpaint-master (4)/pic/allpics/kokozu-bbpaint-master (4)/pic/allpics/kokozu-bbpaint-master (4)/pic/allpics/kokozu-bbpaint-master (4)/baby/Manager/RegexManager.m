//
//  RegexManager.m
//  baby
//
//  Created by zhang da on 14-5-5.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "RegexManager.h"

@implementation RegexManager

+ (bool)isPhoneNum:(NSString *)raw {
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]
                                              initWithPattern:@"^1[3-8]\\d{9}$"
                                              options:NSRegularExpressionCaseInsensitive
                                              error:nil];
    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:raw
                                                                  options:NSMatchingReportProgress
                                                                    range:NSMakeRange(0, raw.length)];
    [regularexpression release];
    return numberofMatch > 0;
}

+ (bool)isUrl:(NSString *)raw {
    NSURL *candidateURL = [NSURL URLWithString:raw];
    return candidateURL && candidateURL.scheme && candidateURL.host;
}

@end
