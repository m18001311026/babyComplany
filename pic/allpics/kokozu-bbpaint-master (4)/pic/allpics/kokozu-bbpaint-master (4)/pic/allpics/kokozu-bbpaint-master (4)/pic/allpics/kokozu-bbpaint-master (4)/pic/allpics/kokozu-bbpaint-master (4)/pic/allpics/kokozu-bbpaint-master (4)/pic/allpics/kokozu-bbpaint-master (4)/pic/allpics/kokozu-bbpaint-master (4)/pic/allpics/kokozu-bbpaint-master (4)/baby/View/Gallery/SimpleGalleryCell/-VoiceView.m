//
//  UserVoiceInfoView.m
//  baby
//
//  Created by zhang da on 14-3-4.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "VoiceView.h"
#import "User.h"
#import "Gallery.h"
#import "ImageView.h"

#import "GalleryPictureLK.h"
#import "Picture.h"
#import "AudioPlayer.h"

@interface VoiceView ()

@property (nonatomic, retain) User *user;
@property (nonatomic, retain) Gallery *gallery;

@end


@implementation VoiceView

- (void)dealloc {
    self.user = nil;
    self.delegate = nil;
    
    [super dealloc];
}

- (void)setGalleryId:(long)galleryId {
    if (_galleryId != galleryId) {
        _galleryId = galleryId;
        self.gallery = [Gallery getGalleryWithId:galleryId];
        self.user = [User getUserWithId:self.gallery.userId];
    } else if ((!self.gallery || !self.user) && _galleryId > 0) {
        self.gallery = [Gallery getGalleryWithId:galleryId];
        self.user = [User getUserWithId:self.gallery.userId];
    }
}

- (void)setIsPlaying:(bool)isPlaying {
    if (_isPlaying != isPlaying) {
        _isPlaying = isPlaying;
        
        if (_isPlaying) {
            [loading startAnimating];
            playIndicator.hidden = YES;
            voiceLengthLabel.hidden = YES;
        } else {
            [loading stopAnimating];
            playIndicator.hidden = NO;
            voiceLengthLabel.hidden = NO;
        }
    }
}

- (void)setVoiceLength:(int)voiceLength {
    if (_voiceLength != voiceLength) {
        _voiceLength = voiceLength;
        voiceLengthLabel.text = [NSString stringWithFormat:@"%d”", voiceLength];
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView *bg = [[UIImageView alloc] init];// initWithImage:[UIImage imageNamed:@"voice_info.png"]];
        bg.frame = CGRectMake(10, 2, 45, 45);
        bg.backgroundColor = [UIColor colorWithWhite:.2 alpha:.8];
        bg.layer.cornerRadius = 8;
        bg.layer.masksToBounds = YES;
        [self addSubview:bg];
        [bg release];
        
        loading = [[UIActivityIndicatorView alloc]
                   initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        loading.frame = CGRectMake(12, 17, 10, 10);
        loading.hidesWhenStopped = YES;
        [self addSubview:loading];
        [loading release];
        
        playIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(12, 17, 10, 10)];
        playIndicator.image = [UIImage imageNamed:@"play_indicator"];
        //playIndicator.hidden = YES;
        [self addSubview:playIndicator];
        [playIndicator release];
        
        voiceLengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 15, 27, 14)];
        voiceLengthLabel.backgroundColor = [UIColor clearColor];
        voiceLengthLabel.font = [UIFont systemFontOfSize:11];
        voiceLengthLabel.textAlignment = NSTextAlignmentCenter;
        voiceLengthLabel.textColor = [UIColor whiteColor];
        //voiceLengthLabel.hidden = YES;
        [self addSubview:voiceLengthLabel];
        [voiceLengthLabel release];
        
        UIButton *voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        voiceBtn.frame = CGRectMake(10, 2, 45, 45);
        [voiceBtn addTarget:self action:@selector(voiceTouched) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:voiceBtn];
    }
    return self;
}

- (void)updateLayout {
    voiceLengthLabel.text = [NSString stringWithFormat:@"%d”", self.voiceLength];
}

- (void)voiceTouched {
    if (self.delegate) {
        [self.delegate playVoiceForGallery:self.galleryId];
    }
}


@end
