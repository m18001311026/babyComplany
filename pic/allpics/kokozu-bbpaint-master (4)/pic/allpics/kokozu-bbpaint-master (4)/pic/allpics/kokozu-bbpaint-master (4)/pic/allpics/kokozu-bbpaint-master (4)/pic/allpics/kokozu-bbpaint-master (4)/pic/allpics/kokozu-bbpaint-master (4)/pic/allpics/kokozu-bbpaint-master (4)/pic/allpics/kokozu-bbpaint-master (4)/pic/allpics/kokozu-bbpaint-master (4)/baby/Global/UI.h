//
//  UI.h
//  baby
//
//  Created by zhang da on 14-3-4.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UI : NSObject

+ (void)showAlert:(NSString *)content;

+ (void)showIndicator;
+ (void)hideIndicator;

@end
