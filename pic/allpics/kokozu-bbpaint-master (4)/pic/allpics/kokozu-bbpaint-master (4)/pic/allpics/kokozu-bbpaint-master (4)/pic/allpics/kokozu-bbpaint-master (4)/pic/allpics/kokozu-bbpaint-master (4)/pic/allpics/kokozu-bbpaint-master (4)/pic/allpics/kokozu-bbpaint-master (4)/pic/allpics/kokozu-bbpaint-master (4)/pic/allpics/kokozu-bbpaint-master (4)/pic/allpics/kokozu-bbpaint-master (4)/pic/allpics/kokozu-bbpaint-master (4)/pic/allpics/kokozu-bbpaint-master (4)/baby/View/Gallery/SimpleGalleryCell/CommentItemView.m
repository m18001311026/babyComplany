//
//  LCommentCell.m
//  baby
//
//  Created by zhang da on 14-3-6.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "CommentItemView.h"
#import "ImageView.h"
#import "GComment.h"
#import "User.h"
#import "MemContainer.h"
#import "ConfManager.h"

#define COMMENT_X 0
#define ICON_WIDTH 20

#define DEFAULTCOMMENT_HEIGHT 30
#define DEFAULTVOICE_WIDTH 80
#define DEFAULTEXT_WIDTH 275
#define DEFAULTFONT 13
#define TEXT_ALIGN 2

@interface CommentItemView ()

@property (nonatomic, retain) GComment *comment;

@end


@implementation CommentItemView

- (void)dealloc {
    self.comment = nil;
    self.delegate = nil;
    [voiceBtn release];
    
    [super dealloc];
}

- (void)setCommentId:(long)commentId {
    if (_commentId != commentId) {
        _commentId = commentId;
        self.comment = [GComment getCommentWithId:_commentId];
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(COMMENT_X, 28, DEFAULTEXT_WIDTH, 20)];
        contentLabel.textColor = [UIColor darkGrayColor];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.numberOfLines = 0;
        contentLabel.font = [UIFont systemFontOfSize:DEFAULTFONT];
        [self addSubview:contentLabel];
        [contentLabel release];
        
        voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        voiceBtn.frame = CGRectMake(146, (DEFAULTCOMMENT_HEIGHT - 30)/2, DEFAULTVOICE_WIDTH, 26);
        [voiceBtn setBackgroundColor:[UIColor orangeColor]];
        [voiceBtn addTarget:self action:@selector(playVoice) forControlEvents:UIControlEventTouchUpInside];
        [voiceBtn.layer setCornerRadius:13];
        [voiceBtn retain];
        
        loading = [[UIActivityIndicatorView alloc]
                   initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loading.frame = CGRectMake(DEFAULTVOICE_WIDTH - 20, (voiceBtn.frame.size.height - 14)/2, 14, 14);
        loading.hidesWhenStopped = YES;
        [voiceBtn addSubview:loading];
        [loading release];
        
        playIndicator = [[UIImageView alloc] initWithFrame:
                         CGRectMake(DEFAULTVOICE_WIDTH - 18, (voiceBtn.frame.size.height - 10)/2, 10, 10)];
        playIndicator.image = [UIImage imageNamed:@"play_indicator"];
        [voiceBtn addSubview:playIndicator];
        [playIndicator release];
        
        voiceLength = [[UILabel alloc] initWithFrame:CGRectMake(6, (voiceBtn.frame.size.height - 14)/2, 30, 14)];
        voiceLength.textColor = [UIColor whiteColor];
        voiceLength.backgroundColor = [UIColor clearColor];
        voiceLength.font = [UIFont systemFontOfSize:12];
        [voiceBtn addSubview:voiceLength];
        [voiceLength release];
        
        deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.frame = CGRectZero;
        [deleteBtn setImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
        [deleteBtn setImageEdgeInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
        [deleteBtn addTarget:self action:@selector(deleteComment) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:deleteBtn];
    }
    return self;
}

- (void)prepareForReuse {

}

- (void)drawRect:(CGRect)rect {
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    [[UIColor colorWithWhite:0.8 alpha:.4] set];
//    CGContextSetLineWidth(context, 1);
//    CGContextMoveToPoint(context, 0, rect.size.height - 1);
//    CGContextAddLineToPoint(context, 320, rect.size.height - 1);
//    CGContextClosePath(context);
//    CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)playVoice {
    if (self.delegate && [self.delegate respondsToSelector:@selector(playVoice:url:)]) {
        [self.delegate playVoice:self url:self.comment.voice];
    }
}

- (void)updateLayout {
    User *user = [User getUserWithId:self.comment.userId];    
    if (self.comment.content) {
        [voiceBtn removeFromSuperview];
        
        NSString *text = [NSString stringWithFormat:@"%@: %@", user.userNickname, self.comment.content];
        CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:DEFAULTFONT]
                           constrainedToSize:CGSizeMake(DEFAULTEXT_WIDTH, INFINITY)
                               lineBreakMode:NSLineBreakByCharWrapping];
        
        if (textSize.height + TEXT_ALIGN > DEFAULTCOMMENT_HEIGHT) {
            contentLabel.frame = CGRectMake(COMMENT_X, TEXT_ALIGN, DEFAULTEXT_WIDTH, self.frame.size.height - 2*TEXT_ALIGN);
        } else {
            contentLabel.frame = CGRectMake(COMMENT_X,
                                            (DEFAULTCOMMENT_HEIGHT - textSize.height)/2,
                                            DEFAULTEXT_WIDTH,
                                            textSize.height);
        }
        contentLabel.text = text;
    } else {
        [self addSubview:voiceBtn];

        NSString *text = [NSString stringWithFormat:@"%@: ", user.userNickname];
        CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:DEFAULTFONT]
                           constrainedToSize:CGSizeMake(DEFAULTEXT_WIDTH, INFINITY)
                               lineBreakMode:NSLineBreakByCharWrapping];
        contentLabel.frame = CGRectMake(COMMENT_X,
                                        (DEFAULTCOMMENT_HEIGHT - DEFAULTFONT + 1)/2,
                                        MIN(textSize.width, DEFAULTEXT_WIDTH - DEFAULTVOICE_WIDTH),
                                        DEFAULTFONT + 1);
        contentLabel.text = text;
        voiceBtn.frame = CGRectMake(contentLabel.frame.origin.x + contentLabel.frame.size.width,
                                    (DEFAULTCOMMENT_HEIGHT - 26)/2,
                                    DEFAULTVOICE_WIDTH,
                                    26);
        voiceLength.text = [NSString stringWithFormat:@"%d\"", self.comment.voiceLength];
        if (self.loadingVoice) {
            [loading startAnimating];
            playIndicator.hidden = YES;
        } else {
            [loading stopAnimating];
            playIndicator.hidden = NO;
        }
    }
    
    if (self.comment.userId == [ConfManager me].userId) {
        deleteBtn.frame = CGRectMake(280, 10, 40, 40);
        deleteBtn.hidden = NO;
    } else {
        deleteBtn.hidden = YES;
        deleteBtn.frame = CGRectZero;
    }
}

- (void)deleteComment {
    if (self.delegate && self.commentId) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"确认删除？删除后将无法恢复!"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"删除", nil];
        [alert show];
        [alert release];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.delegate deleteComment:self.commentId];
    }
}

+ (float)height:(long)commentId {
    GComment *comment = [GComment getCommentWithId:commentId];
    User *user = [User getUserWithId:comment.userId];
    
    if (comment.content) {
        NSString *text = [NSString stringWithFormat:@"%@: %@", user.userNickname, comment.content];
        CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:DEFAULTFONT]
                           constrainedToSize:CGSizeMake(DEFAULTEXT_WIDTH, INFINITY)
                               lineBreakMode:NSLineBreakByCharWrapping];
        return MAX(textSize.height + TEXT_ALIGN*2, DEFAULTCOMMENT_HEIGHT);
    } else {
        return DEFAULTCOMMENT_HEIGHT;
    }
    
}

@end
