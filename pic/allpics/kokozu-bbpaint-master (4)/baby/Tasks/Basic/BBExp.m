//
//  BBExp.m
//  baby
//
//  Created by zhang da on 14-3-2.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "BBExp.h"

@implementation BBExp

- (void)dealloc {

    self.msg = nil;
    
    [super dealloc];
}

- (id)initWIthErr:(int)err msg:(NSString *)msg {
    self = [super init];
    if (self) {
        self.errCode = err;
        self.msg = msg;
    }
    return self;
}

- (id)objectForKey:(id)key {
    NSLog(@"-------------- shit !!!! -----------------");
    return nil;
}

@end
