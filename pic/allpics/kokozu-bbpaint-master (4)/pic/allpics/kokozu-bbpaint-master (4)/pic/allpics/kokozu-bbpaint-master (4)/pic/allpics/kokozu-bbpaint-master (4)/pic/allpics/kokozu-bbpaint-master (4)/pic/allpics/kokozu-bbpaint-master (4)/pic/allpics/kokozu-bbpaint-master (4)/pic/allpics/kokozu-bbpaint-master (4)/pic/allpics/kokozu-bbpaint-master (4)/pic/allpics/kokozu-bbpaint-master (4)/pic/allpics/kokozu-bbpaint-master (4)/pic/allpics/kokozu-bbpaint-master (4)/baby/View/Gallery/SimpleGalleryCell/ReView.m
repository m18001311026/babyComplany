//
//  ReViews.m
//  baby
//
//  Created by zhang da on 15/7/12.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import "ReView.h"
#import "ImageView.h"
#import "Gallery.h"
#import "Picture.h"
#import "User.h"


#define ICON_WIDTH 20
#define THUMB_WIDTH 40
#define TITLE_HEIGHT 10
#define THUMB_DEVIDE 5
#define MAX_RE_CNT 5

#define IMAGE_TAG 8000
#define TITLE_TAG 9000
#define MORE_TAG 9999


@implementation ReView

- (void)dealloc {
    self.delegate = nil;
    [reViews release];
    [reTitles release];
    [res release];
    
    [super dealloc];
}

- (void)setGalleryId:(long)galleryId {
    if( _galleryId != galleryId ) {
        _galleryId = galleryId;
        
        [self updateLayout];
    }
}

- (void)updateLayout {
    [res removeAllObjects];
    
    Gallery *g = [Gallery getGalleryWithId:self.galleryId];
    if (g) {
        [res addObject:g];
    }
    
    NSArray *reGalleries = [Gallery getReGalleries:self.galleryId];
    if (reGalleries.count) {
        [res addObjectsFromArray:reGalleries];
    }
    
    for (UIView *view in reViews) {
        [view removeFromSuperview];
    }
    
    for (UILabel *view in reTitles) {
        [view removeFromSuperview];
    }
    
    NSInteger reCnt = res.count;
    float x = 0;
    for (NSInteger i = 0 ; i < reCnt && i < MAX_RE_CNT; i ++ ) {
        Gallery *g = [res objectAtIndex:i];
        
        ImageView *view = [[ImageView alloc] initWithFrame:
                           CGRectMake(ICON_WIDTH + THUMB_WIDTH*i + THUMB_DEVIDE*(i+1), 0, THUMB_WIDTH, THUMB_WIDTH)];
        view.layer.borderWidth = 1;
        view.layer.cornerRadius = 5;
        view.layer.borderColor = [UIColor lightGrayColor].CGColor;
        view.layer.masksToBounds = YES;
        view.userInteractionEnabled = YES;
        view.contentMode = UIViewContentModeScaleAspectFill;
        view.imagePath = [Picture coverForGallery:g._id];
        view.tag = IMAGE_TAG + i;
        [reViews addObject:view];
        [self addSubview:view];
        [view release];
        
        User *u = [User getUserWithId:g.userId];
        
        UILabel *title = [[UILabel alloc] initWithFrame:
                          CGRectMake(ICON_WIDTH + THUMB_WIDTH*i + THUMB_DEVIDE*(i+1), THUMB_WIDTH + 1, THUMB_WIDTH, TITLE_HEIGHT)];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont systemFontOfSize:9];
        [reTitles addObject:title];
        title.tag = TITLE_TAG + i;
        title.text = (i == 0? @"原作": u.userNickname);
        [self addSubview:title];
        [title release];
        
        x = title.frame.origin.x + title.frame.size.width;
    }

    if (reCnt > MAX_RE_CNT) {
        UILabel *showMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(x + THUMB_DEVIDE, 3, THUMB_WIDTH, THUMB_WIDTH)];
        showMoreLabel.font = [UIFont systemFontOfSize:11];
        showMoreLabel.textAlignment = NSTextAlignmentCenter;
        showMoreLabel.numberOfLines = 0;
        showMoreLabel.textColor = [UIColor grayColor];
        showMoreLabel.tag = MORE_TAG;
        if ([g.liked longValue] < 100) {
            showMoreLabel.text = [NSString stringWithFormat:@"%@\n转发", g.liked];
        } else {
            showMoreLabel.text = @"99+\n转发";
        }
        [self addSubview:showMoreLabel];
        [reViews addObject:showMoreLabel];
        [showMoreLabel release];
    }
    
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *reIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, ICON_WIDTH, THUMB_WIDTH + TITLE_HEIGHT-30)];
      //  reIcon.backgroundColor = [UIColor greenColor];
        reIcon.image=[UIImage imageNamed:@"trans.png"];
        [self addSubview:reIcon];
        [reIcon release];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(touched:)];
        [self addGestureRecognizer:tap];
        [tap release];
        
        reViews = [[NSMutableArray alloc] init];
        reTitles = [[NSMutableArray alloc] init];
        res = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)touched:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    for (UIView *v in reViews) {
        if (CGRectContainsPoint(v.frame, point)) {
            if (v.tag == MORE_TAG) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(showAllRe:)]) {
                    [self.delegate showAllRe:self.galleryId];
                }
            } else if (v.tag < TITLE_TAG) {
                NSInteger index = v.tag - IMAGE_TAG;
                if (index < res.count) {
                    Gallery *g = [res objectAtIndex:index];
                    if (self.delegate && [self.delegate respondsToSelector:@selector(showRe:)]) {
                        [self.delegate showRe:g._id];
                    }
                }
            } else if (v.tag > TITLE_TAG) {
                NSInteger index = v.tag - TITLE_TAG;
                if (index < res.count) {
                    Gallery *g = [res objectAtIndex:index];
                    if (self.delegate && [self.delegate respondsToSelector:@selector(showRe:)]) {
                        [self.delegate showRe:g._id];
                    }
                }
            }

        }
    }
}

@end
