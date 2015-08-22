//
//  GridGalleryCell.h
//  baby
//
//  Created by zhang da on 14-3-23.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageView;


@protocol GridGalleryCellDelegate <NSObject>
- (void)galleryTouchedAtRow:(NSInteger)row andCol:(NSInteger)col;
@end



@interface GridGalleryCell : UITableViewCell {
    NSMutableArray *imageViews;
}

@property (nonatomic, readonly) int colCnt;
@property (nonatomic, assign) id<GridGalleryCellDelegate> delegate;
@property (nonatomic, assign) long row;

- (void)setImagePath:(NSString *)imagePath atCol:(int)col;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
             colCnt:(int)colCnt;

@end
