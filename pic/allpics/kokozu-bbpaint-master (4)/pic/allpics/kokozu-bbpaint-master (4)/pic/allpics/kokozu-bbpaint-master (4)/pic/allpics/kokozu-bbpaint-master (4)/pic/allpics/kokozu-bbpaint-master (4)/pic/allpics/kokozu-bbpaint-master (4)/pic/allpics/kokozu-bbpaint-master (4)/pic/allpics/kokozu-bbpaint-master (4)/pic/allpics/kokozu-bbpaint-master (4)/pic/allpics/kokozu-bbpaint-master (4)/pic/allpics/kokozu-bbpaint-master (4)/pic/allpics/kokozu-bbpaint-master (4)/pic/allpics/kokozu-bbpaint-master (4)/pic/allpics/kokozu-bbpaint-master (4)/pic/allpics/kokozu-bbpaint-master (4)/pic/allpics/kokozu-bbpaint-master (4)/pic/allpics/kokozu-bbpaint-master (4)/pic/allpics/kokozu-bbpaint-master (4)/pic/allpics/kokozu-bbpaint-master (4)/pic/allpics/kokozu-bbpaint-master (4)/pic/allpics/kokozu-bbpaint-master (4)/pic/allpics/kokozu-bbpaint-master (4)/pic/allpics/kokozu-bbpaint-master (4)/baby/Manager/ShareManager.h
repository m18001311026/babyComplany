//
//  ShareManager.h
//  baby
//
//  Created by zhang da on 14-5-1.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShareSDK/ShareSDK.h>

typedef void ( ^ShareDone )(bool succeeded);

@interface ShareManager : NSObject

+ (ShareManager *)me;

- (void)showShareMenuWithTitle:(NSString *)title
                       content:(NSString *)content
                         image:(UIImage *)image
                       pageUrl:(NSString *)pageUrl
                      soundUrl:(NSString *)soundUrl;

- (void)showShareMenuWithTitle:(NSString *)title
                       content:(NSString *)content
                      imageUrl:(NSString *)imageUrl
                       pageUrl:(NSString *)pageUrl
                      soundUrl:(NSString *)soundUrl;

@end
