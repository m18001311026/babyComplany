//
//  EditView.h
//  baby
//
//  Created by zhang da on 14-3-18.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TextMode = 0,
    VoiceMode
} EditMode;


@class VoiceMask;

@protocol EditViewDelegate <NSObject>
@required
- (void)newVoice:(NSData *)mp3 length:(int)length;
- (void)newText:(NSString *)text;
@end


@interface EditView : UIView <UITextViewDelegate>{

    UIView *contentHolder;
    UITextView *inputView;

    UIButton *voiceBtn;
    UIButton *modeSwitchBtn;
    UIButton *delBtn;

    VoiceMask *voiceMask;
    
}

@property (nonatomic, assign) EditMode editMode;
@property (nonatomic, assign) id<EditViewDelegate> delegate;

- (void)resetText;

@end
