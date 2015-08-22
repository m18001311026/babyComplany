//
//  AudioManager.h
//  baby
//
//  Created by zhang da on 14-3-3.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVAudioRecorder;

@interface AudioRecorder : NSObject

+ (void)startRecord;
+ (void)stopRecord;

/* 录音音量 0~1 */
+ (double)volumn;

+ (NSData *)dumpMP3;
+ (NSString *)cafFile;
+ (NSTimeInterval)voiceLength;
+ (void)reset;

@end
