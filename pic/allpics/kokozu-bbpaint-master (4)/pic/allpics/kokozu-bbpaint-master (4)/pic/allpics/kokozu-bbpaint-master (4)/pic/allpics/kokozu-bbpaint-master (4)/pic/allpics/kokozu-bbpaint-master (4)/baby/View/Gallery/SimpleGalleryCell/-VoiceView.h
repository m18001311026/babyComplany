//
//  UserVoiceInfoView.h
//  baby
//
//  Created by zhang da on 14-3-4.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageView;
@class VoiceView;


@protocol VoiceViewDelegate <NSObject>

@required
- (void)playVoiceForGallery:(long)galleryId;
@end


@interface VoiceView : UIView {
    UIImageView *playIndicator;
    UIActivityIndicatorView *loading;
    
    UILabel *voiceLengthLabel;
}

@property (nonatomic, assign) int voiceLength;
@property (nonatomic, assign) bool isPlaying;
@property (nonatomic, assign) long galleryId;
@property (nonatomic, assign) id<VoiceViewDelegate> delegate;

- (void)updateLayout;

@end
