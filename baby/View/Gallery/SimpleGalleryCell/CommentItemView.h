//
//  CommentCell.h
//  baby
//
//  Created by zhang da on 14-3-6.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageView;
@class CommentItemView;


@protocol CommentItemViewDelegate <NSObject>

@required
- (void)playVoice:(CommentItemView *)cell url:(NSString *)voicePath;
- (void)deleteComment:(long)commentId;
@end


@interface CommentItemView : UIView {

    UIImageView *playIndicator;
    UILabel *contentLabel, *voiceLength;
    UIButton *voiceBtn;
    UIActivityIndicatorView *loading;
    
    UIButton *deleteBtn, *replyBtn;

}

@property (nonatomic, assign) long commentId;
@property (nonatomic, assign) bool loadingVoice;
@property (nonatomic, assign) id<CommentItemViewDelegate> delegate;

- (void)updateLayout;
+ (float)height:(long)commentId;

@end
