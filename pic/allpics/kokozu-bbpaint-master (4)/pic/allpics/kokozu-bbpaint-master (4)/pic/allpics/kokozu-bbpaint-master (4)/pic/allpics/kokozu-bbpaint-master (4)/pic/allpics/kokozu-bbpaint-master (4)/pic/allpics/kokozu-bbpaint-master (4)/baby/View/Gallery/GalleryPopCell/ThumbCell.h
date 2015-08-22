//
//  BookshelfCell.m
//  baby
//
//  Created by zhang da on 15/6/28.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ImageView;

@protocol ThumbCellDelegate <NSObject>
- (void)galleryTouchedAtRow:(NSInteger)row andCol:(NSInteger)col;
@end


@interface ThumbCell : UITableViewCell <UIScrollViewDelegate, UIAlertViewDelegate> {
    
    NSMutableArray *imageViews;
    
}

@property (nonatomic, readonly) int colCnt;
@property (nonatomic, assign) id<ThumbCellDelegate> delegate;
@property (nonatomic, assign) NSInteger row;

- (void)setImagePath:(NSString *)imagePath atCol:(int)col;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
             colCnt:(int)colCnt;
@end