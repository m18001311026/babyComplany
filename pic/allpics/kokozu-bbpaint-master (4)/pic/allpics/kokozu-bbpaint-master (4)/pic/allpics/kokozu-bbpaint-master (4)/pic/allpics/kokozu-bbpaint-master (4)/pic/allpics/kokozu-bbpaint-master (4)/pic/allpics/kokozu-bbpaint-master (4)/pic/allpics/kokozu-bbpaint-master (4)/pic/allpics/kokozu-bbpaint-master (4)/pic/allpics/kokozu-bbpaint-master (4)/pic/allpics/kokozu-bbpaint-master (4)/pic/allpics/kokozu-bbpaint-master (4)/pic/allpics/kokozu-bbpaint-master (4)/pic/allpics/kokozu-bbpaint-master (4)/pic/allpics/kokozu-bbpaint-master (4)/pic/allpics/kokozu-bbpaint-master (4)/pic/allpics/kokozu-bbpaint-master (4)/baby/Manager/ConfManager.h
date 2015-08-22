//
//  ConfManager.h
//  baby
//
//  Created by zhang da on 14-3-2.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Session;

@interface ConfManager : NSObject

+ (ConfManager *)me;

- (void)setSession:(Session *)session;
- (Session *)getSession;
- (NSString *)sessionId;
- (long)userId;

- (void)updateServerVesion:(float)version andReviewStatus:(bool)inReview;
- (float)serverVersion;

+ (NSString *)getCurrentVersion;

@end
