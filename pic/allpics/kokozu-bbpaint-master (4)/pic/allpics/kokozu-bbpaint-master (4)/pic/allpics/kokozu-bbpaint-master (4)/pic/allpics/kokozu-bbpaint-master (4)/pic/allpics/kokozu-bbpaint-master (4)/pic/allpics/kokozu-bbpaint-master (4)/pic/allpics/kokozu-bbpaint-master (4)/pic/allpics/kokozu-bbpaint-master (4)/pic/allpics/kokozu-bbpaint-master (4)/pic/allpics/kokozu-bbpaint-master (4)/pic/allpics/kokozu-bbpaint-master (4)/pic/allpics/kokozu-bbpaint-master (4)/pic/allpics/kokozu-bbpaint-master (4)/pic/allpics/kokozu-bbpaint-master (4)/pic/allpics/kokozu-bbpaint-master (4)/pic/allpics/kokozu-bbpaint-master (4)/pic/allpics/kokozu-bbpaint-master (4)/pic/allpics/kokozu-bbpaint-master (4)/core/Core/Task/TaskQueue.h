//
//  TaskQueue.h
//  TestAsiHttp
//
//  Created by Zhang Da on 11-5-26.
//  Copyright 2010 alfaromeo.dev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BasicTask;

@interface TaskQueue : NSObject {
    NSOperationQueue *operationQueue;
}

+ (TaskQueue *)me;

- (void)suspend;
- (void)resume;

+ (BOOL)addTaskToQueue:(BasicTask *)task;
- (void)cancelAllTasks;

@end
