//
//  JXMultiThreadObject.m
//  Test
//
//  Created by Joe on 13-5-9.
//  Copyright (c) 2013年 Joe. All rights reserved.
//

#import "JXMultiThreadObject.h"

@implementation JXMultiThreadObject
- (id)init {
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("COM.JX.MUTABLEARRAY", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)dealloc {
    dispatch_release(_queue);
    _queue = nil;
    self.container = nil;
    
    [super dealloc];
}

#pragma mark - method over writing
- (NSString *)description {
    return self.container.description;
}

#pragma mark - public method
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [[self.container class] instanceMethodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    [anInvocation retainArguments];
    NSMethodSignature *sig = [anInvocation valueForKey:@"_signature"];
    const char *returnType = sig.methodReturnType;
    //    NSLog(@"%@ = > %@",anInvocation.target, NSStringFromSelector(anInvocation.selector));
    //    NSLog(@"%s",returnType);
    if (!strcmp(returnType, "v")) {
        /** the setter method just use async dispatch 
         remove the barrier to make it faster when u r sure that invacations will not affect each other
         */
//        dispatch_barrier_async(_queue, ^{
//            [anInvocation invokeWithTarget:self.container];
//        });
        dispatch_barrier_sync(_queue, ^{
            [anInvocation invokeWithTarget:self.container];
        });
    }
    else {
        /** all getter method need sync dispatch 
         barrier make sure the result is correct
         getter method need barrier in most ways unless u dont except this */
        dispatch_sync(_queue, ^{
            [anInvocation invokeWithTarget:self.container];
        });
    }
}

@end
