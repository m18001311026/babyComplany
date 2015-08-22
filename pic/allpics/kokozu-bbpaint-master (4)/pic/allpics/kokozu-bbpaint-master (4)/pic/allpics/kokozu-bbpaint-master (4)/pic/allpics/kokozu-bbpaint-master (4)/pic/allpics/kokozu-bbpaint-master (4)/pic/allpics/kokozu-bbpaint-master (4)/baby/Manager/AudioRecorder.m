//
//  AudioManager.m
//  baby
//
//  Created by zhang da on 14-3-3.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "AudioRecorder.h"
#import "lame.h"
#import <AVFoundation/AVFoundation.h>

#define VOICE_FILE_DIR @"voice"

@implementation AudioRecorder

static AVAudioRecorder *recorder = nil;
static bool isRecording = NO;
static NSTimeInterval begin = 0, interval = 0;
static NSString *tmpCafFile, *tmpMp3File;

- (void)dealloc {
    
    [super dealloc];
}

+ (void)checkVoiceFilePath {
    NSString *voiceFilePath = [NSTemporaryDirectory() stringByAppendingFormat:@"%@/", VOICE_FILE_DIR];
    if (![[NSFileManager defaultManager] fileExistsAtPath:voiceFilePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:voiceFilePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
}

+ (void)startRecord {
    [self checkVoiceFilePath];
    
    PermissionBlock startRecord = ^(BOOL hasPermission) {
        if (hasPermission && !isRecording) {
            
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
            [audioSession setActive:YES error:nil];
            
            isRecording = YES;
            begin = [NSDate timeIntervalSinceReferenceDate];
            interval = 0;
            
            NSDictionary *recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                           [NSNumber numberWithFloat:8000.00], AVSampleRateKey,
                                           [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                           [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                           [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                           [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                           [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                           nil];
            NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
            [tmpCafFile release];
            [tmpMp3File release];
            tmpCafFile = [[NSString stringWithFormat:@"%f.caf", time] retain];
            tmpMp3File = [[NSString stringWithFormat:@"%f.mp3", time] retain];
            NSURL *cafFile = [NSURL fileURLWithPath:
                              [NSTemporaryDirectory() stringByAppendingFormat:@"%@/%@", VOICE_FILE_DIR, tmpCafFile]];
            NSError* error;

            recorder = [[AVAudioRecorder alloc] initWithURL:cafFile settings:recordSetting error:&error];
            recorder.meteringEnabled = YES;
            [recorder prepareToRecord];
            [recorder record];

        }
    };

    if([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]){
        [[AVAudioSession sharedInstance] requestRecordPermission:startRecord];
    } else {
        startRecord(YES);
    }
}


+ (void)stopRecord {
    PermissionBlock stopRecord = ^(BOOL hasPermission) {
        if (hasPermission && isRecording) {
            interval = [NSDate timeIntervalSinceReferenceDate] - begin;

            if (recorder) {
                [recorder stop];
                [recorder release];
                recorder = nil;
            }
            
            isRecording = NO;
        }
    };
    
    if([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]){
        [[AVAudioSession sharedInstance] requestRecordPermission:stopRecord];
    } else {
        stopRecord(YES);
    }
}

+ (double)volumn {
    if (isRecording) {
        [recorder updateMeters];//刷新音量数据
        //获取音量的平均值  [recorder averagePowerForChannel:0];
        //音量的最大值  [recorder peakPowerForChannel:0];
        return pow(10, (0.05 * [recorder peakPowerForChannel:0]));
    }
    return 0;
}

+ (NSTimeInterval)voiceLength {
    return interval;
}

+ (NSString *)cafFile {
    return [NSTemporaryDirectory() stringByAppendingFormat:@"%@/%@", VOICE_FILE_DIR, tmpCafFile];
}

+ (NSData *)dumpMP3 {
    NSString *cafFilePath =[self cafFile];
    NSString *mp3FilePath = [NSTemporaryDirectory() stringByAppendingFormat:@"%@/%@", VOICE_FILE_DIR, tmpMp3File];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:mp3FilePath]) {
        return [NSData dataWithContentsOfFile:mp3FilePath];
    } else {
        @try {
            int read, write;
            
            FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source
            fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
            FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output
            
            const int PCM_SIZE = 8192;
            const int MP3_SIZE = 8192;
            short int pcm_buffer[PCM_SIZE*2];
            unsigned char mp3_buffer[MP3_SIZE];
            
            lame_t lame = lame_init();
            lame_set_in_samplerate(lame, 8000);
            lame_set_VBR(lame, vbr_default);
            lame_init_params(lame);
            
            do {
                read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
                if (read == 0)
                    write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
                else
                    write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                
                fwrite(mp3_buffer, write, 1, mp3);
                
            } while (read != 0);
            
            lame_close(lame);
            fclose(mp3);
            fclose(pcm);
            
            return [NSData dataWithContentsOfFile:mp3FilePath];
        } @catch (NSException *exception) {
            NSLog(@"%@",[exception description]);
        } @finally {
            
        }
    }
}

+ (void)reset {
    [[NSFileManager defaultManager] removeItemAtPath:[NSTemporaryDirectory() stringByAppendingFormat:@"%@/", VOICE_FILE_DIR] error:nil];
    [tmpCafFile release]; tmpCafFile = nil;
    [tmpMp3File release]; tmpMp3File = nil;
    interval = 0;
}


@end
