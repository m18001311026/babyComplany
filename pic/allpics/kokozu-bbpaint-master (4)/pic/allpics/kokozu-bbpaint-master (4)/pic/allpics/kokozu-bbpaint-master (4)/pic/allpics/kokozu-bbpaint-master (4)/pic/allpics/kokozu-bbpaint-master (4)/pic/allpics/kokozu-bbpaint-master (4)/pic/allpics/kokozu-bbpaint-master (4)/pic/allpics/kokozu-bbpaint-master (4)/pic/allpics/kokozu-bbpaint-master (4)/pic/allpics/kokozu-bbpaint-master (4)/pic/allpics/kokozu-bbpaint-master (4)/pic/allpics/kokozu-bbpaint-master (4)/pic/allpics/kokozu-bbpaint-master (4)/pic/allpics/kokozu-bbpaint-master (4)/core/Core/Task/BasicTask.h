//
//  BasicTask.h
//  alfaromeo.dev
//
//  Created by zhang da on 11-5-16.
//  Copyright 2011 alfaromeo.dev. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    Normal,
    Executing,
    Canceled,
    Finished
} BasicTaskState;


@protocol TaskInterface <NSObject>
/*
 以下方法全部运行于operation的独立线程，非主线程
 */
@required
- (void)operationWillStart;
- (void)operationWillCancel;
- (void)operationWillFinish;
@end


@interface BasicTask : NSOperation {
@private
    NSThread *_runloopThread;
}

@property (nonatomic, assign) NSObject<TaskInterface> *impl;
@property (nonatomic, assign, readonly) BasicTaskState state;
@property (nonatomic, readonly) NSString *taskId;

- (void)finishWithError:(NSError *)error;

@end
