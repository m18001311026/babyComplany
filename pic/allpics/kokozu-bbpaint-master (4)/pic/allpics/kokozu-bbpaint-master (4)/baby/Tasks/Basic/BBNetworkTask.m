//
//  BBNetworkTask.m
//  baby
//
//  Created by zhang da on 14-2-5.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "BBNetworkTask.h"
#import "NSStringExtra.h"
#import "RequestParameter.h"
#import "Constants.h"
#import "BBExp.h"

@implementation BBNetworkTask

- (id)init {
    self = [super init];
    if (self) {
        self.rawData = NO;
        self.delegate = self;
    }
    return self;
}

- (id)initWithUrl:(NSString *)url method:(RequestMethod)method {
    self = [super initWithUrl:url method:method delegate:self];
    if (self) {

    }
    return self;
}

- (id)initWithUrl:(NSString *)url method:(RequestMethod)method session:(NSString *)session {
    self = [super initWithUrl:url method:method delegate:self];
    if (self) {
        self.session = session;
    }
    return self;
}


- (void)dealloc {
    self.responseCallbackBlock = nil;
    self.logicCallbackBlock = nil;
    self.session = nil;
    
    [super dealloc];
}

- (void)appendVerifyInfo {
    if (self.session) {
        [self addHeader:@"session_id" value:self.session];
    }
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970]*1000;
    long long dTime = [[NSNumber numberWithDouble:time] longLongValue];
    [self addParameter:@"time_stamp" value:[NSString stringWithFormat:@"%llu", dTime]];
    
    NSMutableString *toMD5 = [[NSMutableString alloc] init];
    for (RequestParameter *requestParameter in _reqParams) {
        if (![requestParameter valueIsData]) {
            [toMD5 appendString:[requestParameter value]];            
        }
    }
    [toMD5 appendString:MD5KEY];
    
    RequestParameter *newPara = [[RequestParameter alloc] initWithName:@"enc"
                                                                 value:[[toMD5 MD5String] lowercaseString]
                                                                   enc:NSUTF8StringEncoding];
    //DLog(@"----------before:%@", toMD5);
    [_reqParams addObject:newPara];
    [newPara release];
    [toMD5 release];
}

- (void)makeRequest {
    [self appendVerifyInfo];
    [self addHeader:@"Accept-Encoding" value:@"gzip,deflate"];
    [self addHeader:@"channel_id" value:CHANNEL];
}

- (void)handleResponse:(NSData *)data status:(int)status {
    if (status == 200) {
        id result = nil;
        
        if (self.rawData) {
            NSLog(@"\n\n########request:%@#########\n|downloaded\n############################\n\n", self.taskId);
            result = data;
        } else {
#warning NSJSONSerialization only support data in utf8
            result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
#ifdef DEBUG
            if (result) {
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result
                                                                   options:NSJSONWritingPrettyPrinted
                                                                     error:nil];
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                NSLog(@"\n\n########request:%@#########\n|result:%@\n############################\n\n", self.taskId, jsonString);
                [jsonString release];
            } else {
                NSString *error = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"\n\n########request:%@#########\n|result:%@\n############################\n\n", self.taskId, error);
                [error release];
            }
#endif
        }

        if ([result isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)result;
            NSString *msg = [dict objectForKey:@"error"];
            bool succeeded = (msg.length == 0);
            if (succeeded) {
                self.responseCallbackBlock(YES, result);
                self.responseCallbackBlock = nil;
            } else {
                BBExp *exp = [[BBExp alloc] initWIthErr:status msg:msg];
                self.responseCallbackBlock(NO, exp);
                [exp release];
                self.responseCallbackBlock = nil;
            }
        } else {
            self.responseCallbackBlock(YES, result);
            self.responseCallbackBlock = nil;
        }
    } else {
        NSString *resp = [[NSString alloc] initWithBytes:data length:data.length encoding:NSUTF8StringEncoding];
        BBExp *exp = [[BBExp alloc] initWIthErr:status msg:resp.length? resp: @"网络异常"];
        [resp release];
        self.responseCallbackBlock(NO, exp);
        [exp release];
        self.responseCallbackBlock = nil;
    }
}

- (void)doLogicCallBack:(bool)succeeded info:(id)info {
    if (self.logicCallbackBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([info isKindOfClass:[BBExp class]]) {
                NSLog(@"");
            }
            self.logicCallbackBlock(succeeded, info);
            self.logicCallbackBlock = nil;
        });
    }
}

@end
