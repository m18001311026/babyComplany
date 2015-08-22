//
//  BasicTask.m
//  alfaromeo.dev
//
//  Created by zhang da on 11-5-16.
//  Copyright 2011 alfaromeo.dev. All rights reserved.
//

#import "BasicTask.h"

@implementation BasicTask

- (void)setState:(BasicTaskState)newState {
    @synchronized (self) {
        BasicTaskState  oldState = _state;
        if ( (newState == Executing) || (oldState == Executing) ) {
            [self willChangeValueForKey:@"isExecuting"];
        }
        if (newState == Finished) {
            [self willChangeValueForKey:@"isFinished"];
        }
        _state = newState;
        if (newState == Finished) {
            [self didChangeValueForKey:@"isFinished"];
        }
        if ( (newState == Executing) || (oldState == Executing) ) {
            [self didChangeValueForKey:@"isExecuting"];
        }
    }
}

- (id)init {
    self = [super init];
    if (self != nil) {
        _taskId = [[[NSProcessInfo processInfo] globallyUniqueString] retain];
    }
    return self;
}

- (id)init:(id<TaskInterface>)impl {
    self = [super init];
    if (self != nil) {
        self.impl = impl;
        _taskId = [[[NSProcessInfo processInfo] globallyUniqueString] retain];
    }
    return self;
}

- (void)dealloc {
    //NSLog(@"----task:%d dealloc----", [self threadNum]);

    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [_taskId release]; _taskId = nil;
    self.impl = nil;
    _runloopThread = nil;
    
    [super dealloc];
}

- (int)threadNum {
    return [[[NSThread currentThread] valueForKeyPath:@"private.seqNum"] intValue];
}


#pragma mark - running support utility
- (void)finishWithError:(NSError *)error {
    [self callSelOnImpl:@selector(operationWillFinish)];
    self.state = Finished;
}

/*
 * 调用实现类的协议方法，所有方法均在实际运行线程执行
 */
- (void)callSelOnImpl:(SEL)selector {
    if (self.impl && [self.impl respondsToSelector:selector]) {
        if ([NSThread currentThread] != _runloopThread && _runloopThread) {
            [self.impl performSelector:selector
                              onThread:_runloopThread
                            withObject:nil
                         waitUntilDone:YES
                                 modes:@[NSRunLoopCommonModes]];
        
        } else {
            [self.impl performSelector:selector withObject:nil];
        }
    }
}


#pragma mark * Overrides
- (BOOL)isConcurrent {
    return YES;//返回yes表示支持异步调用，否则为支持同步调用
}

- (BOOL)isExecuting {
    return self.state == Executing;
}

- (BOOL)isFinished {
    return self.state == Finished;
}

- (BOOL)isCancelled  {
    return self.state == Canceled;
}

- (void)start {
    _runloopThread = [NSThread currentThread];

    if ([self isFinished] || [self isCancelled]) {
        [self finishWithError:nil];
    }
    
    //NSLog(@"----task:%d start----", [self threadNum]);
    self.state = Executing;
    @autoreleasepool {
        [self callSelOnImpl:@selector(operationWillStart)];

        //NSLog(@"----task:%d waiting----", [self threadNum]);
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        while (![self isFinished]
               && [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {}
    
        //NSLog(@"----task:%d stop----", [self threadNum]);
    }
}

- (void)cancel {
    //NSLog(@"----task:%d cancel----", [self threadNum]);
    
    [self callSelOnImpl:@selector(operationWillCancel)];
    if ([self isExecuting]) {
        self.state = Canceled;
        /*
         如果正在执行，则取消并结束线程。如果没有执行，不结束任务。否则可能加入队列后，还没有start就取消，会报错
         */
        [self finishWithError:nil];
    } else {
        /*
         如果没有执行，只取消状态。如果没有执行，不结束任务。否则可能加入队列后，还没有start就取消，会报错
         */
        self.state = Canceled;
    }
}

@end
