//
//  ReViews.h
//  baby
//
//  Created by zhang da on 15/7/12.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentItemView.h"

@class CommentView;

@protocol CommentViewDelegate <NSObject>

@required
- (bool)commentView:(CommentView*)view shouldStartPlay:(long)commentId;
@end


@interface CommentView : UIView <CommentItemViewDelegate> {
    NSMutableArray *commentViews;
}

@property (nonatomic, assign) long galleryId;
@property (nonatomic, assign) long playingCommentId;


+ (float)viewHeight:(NSArray *)comments;
- (void)stopPlay;
- (void)updateLayout;

@end
