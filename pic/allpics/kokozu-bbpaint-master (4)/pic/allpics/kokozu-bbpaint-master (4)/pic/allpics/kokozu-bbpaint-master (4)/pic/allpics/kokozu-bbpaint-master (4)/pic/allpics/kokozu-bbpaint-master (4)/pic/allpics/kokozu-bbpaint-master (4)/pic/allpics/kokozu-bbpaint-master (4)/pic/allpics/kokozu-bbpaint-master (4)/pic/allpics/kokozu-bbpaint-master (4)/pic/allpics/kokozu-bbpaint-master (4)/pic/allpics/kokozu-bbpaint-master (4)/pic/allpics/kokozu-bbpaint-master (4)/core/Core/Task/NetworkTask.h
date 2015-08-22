//
//  NetworkTask.h
//  alfaromeo.dev
//
//  Created by zhang da on 11-5-16.
//  Copyright 2011 alfaromeo.dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicTask.h"


/*
 * 请求方式，get post 或者put等
 */
typedef enum {
    GET,
    POST,
    PUT,
    DELETE
} RequestMethod;


/*
 * delegate的必须遵守的协议
 */
@protocol NetworkTaskDelegate <NSObject>

@required
- (void)makeRequest;
- (void)handleResponse:(NSData *)data status:(int)status;

@optional
- (void)requestSucceededResponse;
- (void)uploadBytesWritten:(NSInteger)written
         totalBytesWritten:(NSInteger)totalWritten
 totalBytesExpectedToWrite:(NSInteger)totalExpectedToWrite;

@end


/*
 * 请求类
 */
@interface NetworkTask : BasicTask <TaskInterface> {
@protected
    NSMutableArray *_reqParams;
    NSMutableDictionary *_reqHeaders;
    NSMutableData *_respData;
    NSURLConnection *_reqConnection;
    BOOL _isFormRequest;
}

@property (nonatomic, assign) id<NetworkTaskDelegate> delegate;

- (id)initWithUrl:(NSString *)url method:(RequestMethod)method delegate:(id<NetworkTaskDelegate>)delegate;

- (void)addHeader:(NSString *)key value:(NSString *)value;
- (void)addParameter:(NSString *)key value:(NSString *)value;
- (void)addParameter:(NSString *)key value:(NSData *)value fileName:(NSString *)filename;

@end
