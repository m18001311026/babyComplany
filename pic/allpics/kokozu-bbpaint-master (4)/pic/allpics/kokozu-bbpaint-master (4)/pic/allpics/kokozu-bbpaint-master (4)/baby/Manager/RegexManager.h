//
//  RegexManager.h
//  baby
//
//  Created by zhang da on 14-5-5.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegexManager : NSObject

+ (bool)isPhoneNum:(NSString *)raw;
+ (bool)isUrl:(NSString *)raw;

@end
