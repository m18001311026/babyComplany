//
//  BookshelfCell.m
//  baby
//
//  Created by zhang da on 15/6/28.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThumbCell.h"
#import "ImageView.h"

#define DELTA 20

@interface ThumbCell ()


@end


@implementation ThumbCell

- (void)dealloc {
    [imageViews release];
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
             colCnt:(int)colCnt {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _colCnt = colCnt;
        imageViews = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(touched:)];
        [self addGestureRecognizer:tap];
        [tap release];
        
        [self layoutGallery];
    }
    return self;
}

- (void)layoutGallery {
    for (ImageView *v in imageViews) {
        [v removeFromSuperview];
    }
    [imageViews removeAllObjects];
    
    float width = (320.f - self.colCnt - 1 - DELTA*(self.colCnt+1))/self.colCnt;
    
    for (int i = 0; i < _colCnt; i++) {
        ImageView *thumb = [[ImageView alloc] init];
        thumb.backgroundColor = [UIColor clearColor];
        thumb.frame = CGRectMake(width*i + i + 1 + DELTA*(i+1), 0, width, width);
        [self addSubview:thumb];
        [imageViews addObject:thumb];
        [thumb release];
    }
    
}

- (void)setImagePath:(NSString *)imagePath atCol:(int)col {
    if (imageViews.count > col) {
        ImageView *v = [imageViews objectAtIndex:col];
        v.imagePath = imagePath;
    }
}

- (void)touched:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    for (ImageView *v in imageViews) {
        if ([v superview] && CGRectContainsPoint(v.frame, point) && v.imagePath) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(galleryTouchedAtRow:andCol:)]) {
                [self.delegate galleryTouchedAtRow:self.row andCol:[imageViews indexOfObject:v]];
                break;
            }
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end