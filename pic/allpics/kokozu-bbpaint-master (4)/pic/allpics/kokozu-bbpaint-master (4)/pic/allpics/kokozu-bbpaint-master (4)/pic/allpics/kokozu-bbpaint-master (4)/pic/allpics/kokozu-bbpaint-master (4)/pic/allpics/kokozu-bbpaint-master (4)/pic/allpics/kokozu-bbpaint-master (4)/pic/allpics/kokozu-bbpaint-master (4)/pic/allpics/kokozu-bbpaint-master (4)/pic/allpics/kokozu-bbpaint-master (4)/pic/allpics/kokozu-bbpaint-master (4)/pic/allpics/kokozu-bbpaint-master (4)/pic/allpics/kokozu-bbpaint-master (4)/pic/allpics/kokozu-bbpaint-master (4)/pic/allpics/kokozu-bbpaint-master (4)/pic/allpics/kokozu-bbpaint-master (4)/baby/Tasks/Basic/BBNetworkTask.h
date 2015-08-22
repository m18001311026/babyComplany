//
//  BBNetworkTask.h
//  baby
//
//  Created by zhang da on 14-2-5.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "NetworkTask.h"

typedef void ( ^CallbackBlock )(bool succeeded, id userInfo);

@interface BBNetworkTask : NetworkTask <NetworkTaskDelegate> {

}

@property (nonatomic, assign) bool rawData;
@property (nonatomic, retain) NSString *session;
@property (copy) CallbackBlock responseCallbackBlock;
@property (copy) CallbackBlock logicCallbackBlock;

- (id)initWithUrl:(NSString *)url method:(RequestMethod)method session:(NSString *)session;
- (id)initWithUrl:(NSString *)url method:(RequestMethod)method;
- (void)doLogicCallBack:(bool)succeeded info:(id)info;

@end
