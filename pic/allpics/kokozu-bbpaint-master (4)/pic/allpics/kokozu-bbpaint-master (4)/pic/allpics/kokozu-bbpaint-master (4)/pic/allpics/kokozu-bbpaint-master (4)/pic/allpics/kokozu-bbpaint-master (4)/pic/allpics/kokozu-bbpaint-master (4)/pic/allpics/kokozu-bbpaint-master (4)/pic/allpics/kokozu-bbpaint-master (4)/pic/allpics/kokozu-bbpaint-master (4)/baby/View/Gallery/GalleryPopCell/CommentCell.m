//
//  CommentCell.m
//  baby
//
//  Created by zhang da on 14-3-6.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "CommentCell.h"
#import "ImageView.h"
#import "GComment.h"
#import "User.h"
#import "MemContainer.h"
#import "ConfManager.h"


@interface CommentCell ()

@property (nonatomic, retain) GComment *comment;

@end


@implementation CommentCell

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
    } else if (!self.comment && _commentId > 0) {
        self.comment = [GComment getCommentWithId:_commentId];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        avatar = [[ImageView alloc] initWithImage:[UIImage imageNamed:@"baby_logo.png"]];
        avatar.frame = CGRectMake(10, 10, 40, 40);
        avatar.layer.cornerRadius = 20;
        avatar.layer.borderColor = [Shared bbGray].CGColor;
        avatar.layer.borderWidth = 1;
        avatar.layer.masksToBounds = YES;
        [self addSubview:avatar];
        [avatar release];
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 28, 220, 20)];
        contentLabel.textColor = [UIColor darkGrayColor];
        contentLabel.backgroundColor = [UIColor whiteColor];
        contentLabel.numberOfLines = 0;
        contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
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
        loading.frame = CGRectMake(DEFAULTVOICE_WIDTH - 20,
                                   (voiceBtn.frame.size.height - 14)/2, 14, 14);
        loading.hidesWhenStopped = YES;
        [voiceBtn addSubview:loading];
        [loading release];
        
        playIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(DEFAULTVOICE_WIDTH - 18,
                                                                      (voiceBtn.frame.size.height - 10)/2, 10, 10)];
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
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0);
    [[UIColor whiteColor] set];
    CGContextAddRect(context, CGRectMake(0, 0, 320, self.frame.size.height));
    CGContextDrawPath(context, kCGPathFillStroke);
    
    [[UIColor colorWithWhite:0.8 alpha:.4] set];
    CGContextSetLineWidth(context, 1);
    CGContextMoveToPoint(context, 0, rect.size.height - 1);
    CGContextAddLineToPoint(context, 320, rect.size.height - 1);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)playVoice {
    if (self.delegate && [self.delegate respondsToSelector:@selector(playVoice:url:)]) {
        [self.delegate playVoice:self url:self.comment.voice];
    }
}

- (void)updateLayout {
    User *user = [User getUserWithId:self.comment.userId];
    avatar.imagePath = user.userPhoto;
    
    if (self.comment._id == 18) {
        NSLog(@"");
    }
    NSString *text = [NSString stringWithFormat:@"%@: %@",
                      user.userNickname,
                      self.comment.content? self.comment.content: @""];
    CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:DEFAULTFONT]
                       constrainedToSize:CGSizeMake(220, INFINITY)
                           lineBreakMode:NSLineBreakByCharWrapping];
    if (textSize.height + 10 > DEFAULTCOMMENT_HEIGHT
        || (self.comment.content.length && self.comment.voice && self.comment.voiceLength)) {
        contentLabel.frame = CGRectMake(60, 5, 220, textSize.height);
    } else {
        if (self.comment.content.length) {
            contentLabel.frame = CGRectMake(60,
                                            (DEFAULTCOMMENT_HEIGHT - textSize.height)/2,
                                            220,
                                            textSize.height);
        } else {
            contentLabel.frame = CGRectMake(60,
                                            (DEFAULTCOMMENT_HEIGHT - DEFAULTFONT + 1)/2,
                                            MIN(textSize.width + 5, 220 - DEFAULTVOICE_WIDTH),
                                            DEFAULTFONT + 1);
        }
    }
    contentLabel.text = text;
    
    if (self.comment.voice) {
        [self addSubview:voiceBtn];
    
        if (self.comment.content.length) {
            voiceBtn.frame = CGRectMake(60,
                                        contentLabel.frame.origin.y + contentLabel.frame.size.height + 5,
                                        DEFAULTVOICE_WIDTH,
                                        26);
        } else {
            voiceBtn.frame = CGRectMake(contentLabel.frame.origin.x + contentLabel.frame.size.width + 5,
                                        (DEFAULTCOMMENT_HEIGHT - 26)/2,
                                        DEFAULTVOICE_WIDTH,
                                        26);
        }
        voiceLength.text = [NSString stringWithFormat:@"%d\"", self.comment.voiceLength];
        if (self.loadingVoice) {
            [loading startAnimating];
            playIndicator.hidden = YES;
        } else {
            [loading stopAnimating];
            playIndicator.hidden = NO;
        }

    } else {
        [voiceBtn removeFromSuperview];
    }
    
    if (self.comment.userId == [ConfManager me].userId) {
        deleteBtn.frame = CGRectMake(280, 10, 40, 40);
        deleteBtn.hidden = NO;
    } else {
        deleteBtn.hidden = YES;
        deleteBtn.frame = CGRectZero;
    }
}

+ (float)height:(long)commentId {
    GComment *comment = [GComment getCommentWithId:commentId];
    User *user = [User getUserWithId:comment.userId];
    
    if (commentId == 17) {
        NSLog(@"");
    }
    
    NSString *text = [NSString stringWithFormat:@"%@: %@",
                      user.userNickname,
                      comment.content? comment.content: @""];
    CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:DEFAULTFONT]
                       constrainedToSize:CGSizeMake(220, INFINITY)
                           lineBreakMode:NSLineBreakByCharWrapping];
    float y = 0;
    if (textSize.height + 10 > DEFAULTCOMMENT_HEIGHT
        || (comment.content.length && comment.voice && comment.voiceLength)) {
        y += 5;
        y += textSize.height;
    }
    
    if (comment.voice && comment.content.length) {
        y += 5;
        y += 26;
        y += 5;
    }
    
    return MAX(DEFAULTCOMMENT_HEIGHT, y);
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

@end
