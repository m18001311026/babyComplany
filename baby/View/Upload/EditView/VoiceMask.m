//
//  VoiceMask.m
//  baby
//
//  Created by zhang da on 14-3-18.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "VoiceMask.h"
#import "AudioRecorder.h"

@implementation VoiceMask

- (void)dealloc {
    [self stopTimer];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
        image.image = [UIImage imageNamed:@"mic_indicator"];
        image.backgroundColor = [UIColor clearColor];
        image.center = CGPointMake(frame.size.width/2.0f, frame.size.height/2.0f);
        [self addSubview:image];
        [image release];
        
        volumnIndicator = [[UIView alloc] initWithFrame:CGRectMake(65, 87, 20, 0)];
        volumnIndicator.backgroundColor = [UIColor orangeColor];
        volumnIndicator.layer.cornerRadius = 10;
        volumnIndicator.layer.masksToBounds = YES;
        [image addSubview:volumnIndicator];
        [volumnIndicator release];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 120, 50, 18)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textAlignment = UITextAlignmentCenter;
        timeLabel.font = [UIFont systemFontOfSize:15];
        timeLabel.textColor = [UIColor whiteColor];
        [image addSubview:timeLabel];
        [timeLabel release];
        
    }
    return self;
}

- (void)startTimer {
    [self stopTimer];
    
    timer = [NSTimer timerWithTimeInterval:0.2
                                    target:self
                                  selector:@selector(updateLayout:)
                                  userInfo:nil
                                   repeats:YES];
    NSRunLoop *runloop=[NSRunLoop currentRunLoop];
    [runloop addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)stopTimer {
    [timer invalidate];
    timer = nil;
}

- (void)startAnimation {
    startTimestamp = [NSDate timeIntervalSinceReferenceDate];
    firetimes = 0;
    [self startTimer];
}

- (void)stopAnimation {
    firetimes = 0;
    [self stopTimer];
}

- (void)updateLayout:(NSTimer *)timer {
    firetimes += 1;
    
    double volume = [AudioRecorder volumn];    
    volumnIndicator.frame = CGRectMake(65, 40 + 47.0f*(1.0f-volume), 20, volume*47.0f);
    
    timeLabel.text =
    [NSString stringWithFormat:@"%d\"", (int)([NSDate timeIntervalSinceReferenceDate] - startTimestamp)];
}

@end
