//
//  CategoryCell.m
//  baby
//
//  Created by zhang da on 15/6/28.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoryCell.h"
#import "ImageView.h"

#define DELTA 20

@interface CategoryCell ()


@end


@implementation CategoryCell

- (void)dealloc {
    [imageViews release];
    [bgViews release];
    [titles release];

    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
             colCnt:(int)colCnt {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];

        _colCnt = colCnt;
        imageViews = [[NSMutableArray alloc] init];
        bgViews = [[NSMutableArray alloc] init];
        titles = [[NSMutableArray alloc] init];

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
    for (UILabel *v in titles) {
        [v removeFromSuperview];
    }
    
    for (UIView *v in bgViews) {
        [v removeFromSuperview];
    }
    
    [imageViews removeAllObjects];
    [bgViews removeAllObjects];
    [titles removeAllObjects];
    
    float width = (300.f - self.colCnt - 1 - DELTA*(self.colCnt+1))/self.colCnt;
    
    for (int i = 0; i < _colCnt; i++) {
        UIView *bg = [[UIView alloc] init];
        bg.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
        bg.layer.borderColor = [UIColor whiteColor].CGColor;
        bg.layer.borderWidth = 2;
        bg.layer.cornerRadius = 4;
        bg.layer.masksToBounds = NO;
        bg.frame = CGRectMake(width*i + i + 1 + DELTA*(i+1), 10, width, 10 + width + 6);
        [self addSubview:bg];
        [bgViews addObject:bg];
        [bg release];

        UILabel *title = [[UILabel alloc] initWithFrame:
                          CGRectMake(width*i + i + 1 + DELTA*(i+1) + 1.5, 10 + width - 1, width - 3, 16)];
        title.textAlignment = NSTextAlignmentCenter;
        title.backgroundColor = [UIColor clearColor];
        title.textColor = [UIColor blackColor];
        title.font = [UIFont systemFontOfSize:9];
        [self addSubview:title];
        [titles addObject:title];
        [title release];
        
        ImageView *thumb = [[ImageView alloc] init];
        thumb.backgroundColor = [UIColor clearColor];
        thumb.contentMode = UIViewContentModeScaleAspectFit;
        thumb.frame = CGRectMake(width*i + i + 1 + DELTA*(i+1) + 3, 13, width - 6, width - 6);
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

- (void)setTitle:(NSString *)title atCol:(int)col {
    if (titles.count > col) {
        UILabel *v = [titles objectAtIndex:col];
        v.text = title;
        v.backgroundColor = title? [UIColor whiteColor]: [UIColor clearColor];
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