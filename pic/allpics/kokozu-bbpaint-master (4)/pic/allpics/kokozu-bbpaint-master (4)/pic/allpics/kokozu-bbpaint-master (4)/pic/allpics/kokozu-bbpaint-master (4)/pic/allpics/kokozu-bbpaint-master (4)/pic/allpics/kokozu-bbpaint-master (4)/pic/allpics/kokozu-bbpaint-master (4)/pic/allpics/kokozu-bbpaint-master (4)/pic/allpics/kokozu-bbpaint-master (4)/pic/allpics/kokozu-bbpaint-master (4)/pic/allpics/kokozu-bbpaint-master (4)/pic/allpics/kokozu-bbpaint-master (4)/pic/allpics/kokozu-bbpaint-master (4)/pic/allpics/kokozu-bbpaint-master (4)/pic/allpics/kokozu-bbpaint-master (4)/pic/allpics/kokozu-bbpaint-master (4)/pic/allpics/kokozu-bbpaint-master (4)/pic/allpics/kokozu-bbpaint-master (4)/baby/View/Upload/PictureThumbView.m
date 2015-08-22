//
//  PictureThumbView.m
//  baby
//
//  Created by zhang da on 14-3-10.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "PictureThumbView.h"
#import "UIImageExtra.h"
#import "AudioPlayer.h"

@implementation PictureThumbView

- (void)dealloc {
    self.voiceFile = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        pictureThumb = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        pictureThumb.contentMode = UIViewContentModeScaleAspectFill;
        pictureThumb.clipsToBounds = YES;
        [self addSubview:pictureThumb];
        [pictureThumb release];
        
        UIButton *playbackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        playbackBtn.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        playbackBtn.contentEdgeInsets = UIEdgeInsetsMake(25, 30, 25, 30);
        [playbackBtn setImage:[UIImage imageNamed:@"play_indicator"] forState:UIControlStateNormal];
        [playbackBtn addTarget:self action:@selector(playback) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:playbackBtn];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    pictureThumb.image = image;
}

- (void)playback {
    [AudioPlayer startPlayFile:self.voiceFile finished:^{
        
    }];
}

@end
