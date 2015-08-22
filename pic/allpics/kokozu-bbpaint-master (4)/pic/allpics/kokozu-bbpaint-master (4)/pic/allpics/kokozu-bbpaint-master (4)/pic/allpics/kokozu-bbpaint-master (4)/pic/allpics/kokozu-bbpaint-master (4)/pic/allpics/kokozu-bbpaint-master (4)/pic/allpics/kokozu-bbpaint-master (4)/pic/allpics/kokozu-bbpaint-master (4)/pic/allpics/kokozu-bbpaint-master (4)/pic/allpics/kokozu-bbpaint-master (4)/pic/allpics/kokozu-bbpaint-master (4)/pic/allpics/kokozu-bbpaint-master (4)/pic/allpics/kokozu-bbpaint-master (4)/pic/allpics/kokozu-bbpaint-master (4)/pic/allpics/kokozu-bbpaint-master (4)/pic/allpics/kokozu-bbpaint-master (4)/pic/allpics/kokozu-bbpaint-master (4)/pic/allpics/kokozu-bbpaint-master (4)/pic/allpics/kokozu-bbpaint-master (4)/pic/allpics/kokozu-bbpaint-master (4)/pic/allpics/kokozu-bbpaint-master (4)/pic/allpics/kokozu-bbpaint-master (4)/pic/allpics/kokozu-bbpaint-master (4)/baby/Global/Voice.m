//
//  Voice.m
//  baby
//
//  Created by zhang da on 14-3-17.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "Voice.h"
#import "Constants.h"
#import "NSStringExtra.h"

#import "VoiceTask.h"
#import "TaskQueue.h"

@implementation Voice

+ (void)createDirection {
    NSString *imgPath = [NSTemporaryDirectory() stringByAppendingString:VOICE_CACHE_FOLDER];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imgPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:imgPath
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
}

+ (NSString *)imageDiskDir:(NSString *)url {
    NSString *fUrl = [url URLEncodedString];
    return [NSTemporaryDirectory() stringByAppendingFormat:@"%@/%@", VOICE_CACHE_FOLDER, fUrl];
}

+ (void)getVoice:(NSString *)url callback:(VoiceDone)callback {
    if (!url) {
        if (callback) {
            callback(url, nil);
        }
    } else {
        [self getVoiceFromDisk:url callback:^(NSString *rUrl, NSData *voice) {
            if (voice) {
                if (callback) {
                    callback(url, voice);
                }
            } else {
                [self getVoiceFromNetwork:url callback:^(NSString *rUrl, NSData *voice) {
                    if (callback) {
                        callback(url, voice);
                    }
                }];
            }
        }];
    }
}

+ (void)getVoiceFromDisk:(NSString *)url callback:(VoiceDone)callback {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSData *voice = [[[NSData alloc] initWithContentsOfFile:[self imageDiskDir:url]] autorelease];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(url, voice);
            }
        });
    });
}

+ (void)getVoiceFromNetwork:(NSString *)url callback:(VoiceDone)callback {
    VoiceTask *task = [[VoiceTask alloc] initGetVoice:url];
    task.logicCallbackBlock = ^(bool succeeded, id userInfo) {
        if (succeeded) {
            NSData *voice = [userInfo objectForKey:@"voice"];
            [self saveVoice:voice withUrl:url sync:NO];
            if (callback) {
                callback(url, voice);
            }
        } else {
            [UI showAlert:@"语音下载失败，请检查当前网络状况"];
            if (callback) {
                callback(url, nil);
            }
        }
    };
    [TaskQueue addTaskToQueue:task];
    [task release];
}

+ (void)saveVoice:(NSData *)voice withUrl:(NSString *)url sync:(bool)sync {
    NSString *imgPath = [self imageDiskDir:url];
    if (sync) {
        if ( ![voice writeToFile:imgPath options:NSAtomicWrite error:nil] ) {
            NSLog(@"save error");
            [self createDirection];
        }
    } else {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            if ( ![voice writeToFile:imgPath options:NSAtomicWrite error:nil] ) {
                NSLog(@"save error");
                [self createDirection];
            }
        });
    }
}

@end
