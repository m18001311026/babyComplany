//
//  TaskQueue.m
//  TestAsiHttp
//
//  Created by Zhang Da on 11-5-26.
//  Copyright 2010 alfaromeo.dev. All rights reserved.
//

#import "TaskQueue.h"
#import "NetworkTask.h"

static TaskQueue *_taskQueue = nil;

@interface TaskQueue (Private)

-(NSOperationQueue *)queue;

@end

@implementation TaskQueue

+ (TaskQueue *)me {
    @synchronized(_taskQueue) {
		if (!_taskQueue) {
			_taskQueue = [[TaskQueue alloc] init];
		}
	}
	return _taskQueue;	
}


#pragma mark Constructors
- (id)init {
    self = [super init];
    if (self) {
        operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue addObserver:self forKeyPath:@"operationCount" options:0 context:NULL];
        [operationQueue setMaxConcurrentOperationCount:50];
    }
    
    return self;
}

-(NSOperationQueue *)queue {
    return operationQueue;
}

- (void)dealloc {
    [operationQueue release];
    [super dealloc];
}

- (void)suspend {
    if (operationQueue && ![operationQueue isSuspended]) {
        [operationQueue setSuspended:YES];
    }
}

- (void)resume {
    if (operationQueue && [operationQueue isSuspended]) {
        [operationQueue setSuspended:NO];
    }
}


#pragma mark Utility
+ (BOOL)addTaskToQueue:(BasicTask *)task {
    
    if (!task || [task isFinished] || [task isCancelled]) return NO;
    [[TaskQueue me] resume];
    [[[TaskQueue me] queue] addOperation:task];
    
    return YES;
}

- (void)cancelAllTasks {
    if (operationQueue) {
        [operationQueue cancelAllOperations];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context {
    if (object == operationQueue && [keyPath isEqualToString:@"operationCount"]) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = ([operationQueue operationCount] > 0);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
