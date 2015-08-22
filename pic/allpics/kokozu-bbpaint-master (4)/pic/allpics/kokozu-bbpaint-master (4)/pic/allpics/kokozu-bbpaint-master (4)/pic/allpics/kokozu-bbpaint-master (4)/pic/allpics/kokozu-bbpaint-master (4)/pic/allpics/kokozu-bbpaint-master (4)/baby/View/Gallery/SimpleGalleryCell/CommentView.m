//
//  ReViews.m
//  baby
//
//  Created by zhang da on 15/7/12.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import "CommentView.h"
#import "ImageView.h"
#import "GComment.h"

#import "Gallery.h"
#import "Picture.h"
#import "AudioPlayer.h"
#import "MemContainer.h"


#define MAX_COMMENT_CNT 5

@implementation CommentView

- (void)dealloc {
    [commentViews release];
    
    [super dealloc];
}

- (void)setGalleryId:(long)galleryId {
    if( _galleryId != galleryId ) {
        _galleryId = galleryId;
    }
    [self updateLayout];
}

- (void)updateLayout {

    for (UIView *view in commentViews) {
        [view removeFromSuperview];
    }
    [commentViews removeAllObjects];
    
    NSArray *comments = [GComment getCommentsForGallery:self.galleryId];
    NSMutableArray *commentIds = [[NSMutableArray alloc] init];
    if (comments) {
        for (GComment *comment in comments) {
            [commentIds addObject:@(comment._id)];
        }
    }
    
    float y = 0;
    for (int i = 0 ; i < commentIds.count && i < MAX_COMMENT_CNT; i ++ ) {
        long commentId = [[commentIds objectAtIndex:i] longValue];
        float height = [CommentItemView height:commentId];
        
        CommentItemView *view = [[CommentItemView alloc] initWithFrame:CGRectMake(25, y, 300, height)];
        view.backgroundColor = [UIColor whiteColor];
        view.clipsToBounds = YES;
        view.userInteractionEnabled = YES;
        view.delegate = self;
        [commentViews addObject:view];
        [self addSubview:view];
        [view release];
        
        view.commentId = commentId;
        if (view.commentId == self.playingCommentId) {
            view.loadingVoice = YES;
        } else {
            view.loadingVoice = NO;
        }
        [view updateLayout];
        
        y += height;
    }
    
    if (comments.count >= MAX_COMMENT_CNT) {
        UILabel *showMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, 300, 20)];
        showMoreLabel.font = [UIFont systemFontOfSize:12];
        showMoreLabel.textAlignment = NSTextAlignmentCenter;
        showMoreLabel.textColor = [UIColor grayColor];
        showMoreLabel.text = @"点击查看更多评论";
        [self addSubview:showMoreLabel];
        [commentViews addObject:showMoreLabel];
        [showMoreLabel release];
    }
    
    [commentIds release];

}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *commentIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 8, 16, 16)];
        //commentIcon.backgroundColor = [UIColor redColor];
        commentIcon.image=[UIImage imageNamed:@"comment2"];
        [self addSubview:commentIcon];
        [commentIcon release];
        
        commentViews = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (float)viewHeight:(NSArray *)comments {
    
    float height = 0;
    for (int i = 0 ; i < comments.count && i < MAX_COMMENT_CNT; i ++ ) {
        long commentId = [[comments objectAtIndex:i] longValue];
        height += [CommentItemView height:commentId];
    }
    if (comments.count >= MAX_COMMENT_CNT) {
        height += 20;
    }
    return height;
}

- (void)stopPlay {

}


#pragma CommentItemViewDelegate
- (void)playVoice:(CommentItemView *)cell url:(NSString *)voicePath {
    [AudioPlayer stopPlay];
    
    if (self.playingCommentId != cell.commentId) {
        [Voice getVoice:voicePath
               callback:^(NSString *url, NSData *voice) {
                   if ([url isEqualToString:voicePath] && voice) {
                       [AudioPlayer startPlayData:voice finished:^{
                           self.playingCommentId = -1;
                           [self updateLayout];
                       }];
                   } else {
                       self.playingCommentId = -1;
                       [self updateLayout];
                   }
               }];
        self.playingCommentId = cell.commentId;
    } else {
        self.playingCommentId = -1;
    }
    
    [self updateLayout];
}

- (void)deleteComment:(long)commentId {
//    GalleryTask *task = [[GalleryTask alloc] initDeleteComment:commentId];
//    [UI showIndicator];
//    task.logicCallbackBlock = ^(bool succeeded, id userInfo) {
//        if (succeeded) {
//            [self loadContent];
//        }
//        [UI hideIndicator];
//    };
//    [TaskQueue addTaskToQueue:task];
//    [task release];
}



@end
