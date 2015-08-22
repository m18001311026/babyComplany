//
//  BBExp.h
//  baby
//
//  Created by zhang da on 14-3-2.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBExp : NSObject

@property (nonatomic, retain) NSString *msg;
@property (nonatomic, assign) int errCode;

- (id)initWIthErr:(int)err msg:(NSString *)msg;
- (id)objectForKey:(id)key;

@end
