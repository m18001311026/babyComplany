//
//  BookshelfCell.m
//  baby
//
//  Created by zhang da on 15/6/28.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ImageView;

@protocol CategoryCellDelegate <NSObject>
- (void)galleryTouchedAtRow:(NSInteger)row andCol:(NSInteger)col;
@end


@interface CategoryCell : UITableViewCell <UIScrollViewDelegate, UIAlertViewDelegate> {
    
    NSMutableArray *imageViews;
    NSMutableArray *bgViews;
    NSMutableArray *titles;

}

@property (nonatomic, readonly) int colCnt;
@property (nonatomic, assign) id<CategoryCellDelegate> delegate;
@property (nonatomic, assign) NSInteger row;

- (void)setImagePath:(NSString *)imagePath atCol:(int)col;
- (void)setTitle:(NSString *)title atCol:(int)col;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
             colCnt:(int)colCnt;
@end