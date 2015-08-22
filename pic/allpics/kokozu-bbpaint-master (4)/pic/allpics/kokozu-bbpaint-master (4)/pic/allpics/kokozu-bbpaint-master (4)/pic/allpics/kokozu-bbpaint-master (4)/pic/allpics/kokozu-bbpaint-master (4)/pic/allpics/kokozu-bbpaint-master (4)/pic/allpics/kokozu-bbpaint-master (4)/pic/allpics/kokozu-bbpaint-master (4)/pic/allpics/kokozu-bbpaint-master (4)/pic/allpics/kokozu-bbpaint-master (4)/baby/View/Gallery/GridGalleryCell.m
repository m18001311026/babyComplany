//
//  GridGalleryCell.m
//  baby
//
//  Created by zhang da on 14-3-23.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "GridGalleryCell.h"
#import "ImageView.h"


@implementation GridGalleryCell

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
    
    float width = (320.f - self.colCnt - 1)/self.colCnt;
    
    for (int i = 0; i < _colCnt; i++) {
        ImageView *thumb = [[ImageView alloc] init];
        thumb.backgroundColor = [UIColor clearColor];
//        thumb.layer.borderWidth = 1;
//        thumb.layer.borderColor = [UIColor lightGrayColor].CGColor;
        thumb.frame = CGRectMake(width*i + i + 1, 0, width, width);
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
