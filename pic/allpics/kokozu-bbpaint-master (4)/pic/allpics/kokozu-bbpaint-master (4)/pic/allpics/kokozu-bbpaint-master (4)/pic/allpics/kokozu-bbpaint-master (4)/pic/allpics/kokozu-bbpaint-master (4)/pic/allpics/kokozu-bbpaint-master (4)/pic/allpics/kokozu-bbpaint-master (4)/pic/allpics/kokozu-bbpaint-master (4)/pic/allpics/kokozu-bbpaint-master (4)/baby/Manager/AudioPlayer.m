//
//  AudioPlayer.m
//  baby
//
//  Created by zhang da on 14-3-11.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "AudioPlayer.h"

@implementation AudioPlayer

static AVAudioPlayer *_player;
static AudioPlayer *_me;

+ (AudioPlayer *)me {
    if (!_me) {
        @synchronized([AudioPlayer class]) {
            if (!_me) {
                _me = [[AudioPlayer alloc] init];
            }
        }
    }
    return _me;
}

- (void)dealloc {
    self.callback = nil;
    
    [super dealloc];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (self.callback) {
        self.callback();
        self.callback = nil;
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"%@", error);
}


+ (void)startPlayFile:(NSString *)file finished:(PlayFinished)block {
    [self stopPlay];
    
    NSLog(@"play: %@", file);
    
    if (!file) {
        return;
    }
    
    AudioSessionInitialize (NULL, NULL, NULL, NULL);
    AudioSessionSetActive(true);
    
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof(audioRouteOverride), &audioRouteOverride);
    
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:file] error:nil];
    _player.delegate = [AudioPlayer me];
    _player.volume = 1;
    [AudioPlayer me].callback = block;
    [_player prepareToPlay];
    [_player play];
    //_player.delegate = self;
}

+ (void)startPlayData:(NSData *)data finished:(PlayFinished)block {
    [self stopPlay];
    
    if (!data) {
        return;
    }
    
    AudioSessionInitialize (NULL, NULL, NULL, NULL);
    AudioSessionSetActive(true);
    
    // Allow playback even if Ring/Silent switch is on mute
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty (kAudioSessionProperty_AudioCategory, sizeof(sessionCategory),&sessionCategory);
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof(audioRouteOverride), &audioRouteOverride);
    
    _player = [[AVAudioPlayer alloc] initWithData:data error:nil];
    _player.delegate = [AudioPlayer me];
    [AudioPlayer me].callback = block;
    [_player prepareToPlay];
    [_player play];
}

+ (void)stopPlay {
    if (_player) {
        [_player stop];
        [_player release];
        [AudioPlayer me].callback = nil;
        _player = nil;
    }
}

@end
