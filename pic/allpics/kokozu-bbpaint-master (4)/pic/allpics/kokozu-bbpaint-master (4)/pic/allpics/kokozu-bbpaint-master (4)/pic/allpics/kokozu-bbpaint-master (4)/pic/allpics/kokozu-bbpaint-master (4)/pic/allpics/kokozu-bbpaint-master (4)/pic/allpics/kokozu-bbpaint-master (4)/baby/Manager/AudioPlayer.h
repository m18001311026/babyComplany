//
//  AudioPlayer.h
//  baby
//
//  Created by zhang da on 14-3-11.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void ( ^PlayFinished )();

@interface AudioPlayer : NSObject <AVAudioPlayerDelegate>

@property (nonatomic, copy) PlayFinished callback;

+ (void)startPlayFile:(NSString *)file finished:(PlayFinished)block;
+ (void)startPlayData:(NSData *)data finished:(PlayFinished)block;
+ (void)stopPlay;

@end
