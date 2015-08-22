//
//  ImageHolder.h
//  KoMovie
//
//  Created by alfaromeo on 12-6-18.
//  Copyright (c) 2012年 kokozu. All rights reserved.
//


@class ImageHolder;


@protocol ImageHolderDelegate <NSObject>

@optional

- (void)imageHolder:(ImageHolder *)holder singleTapAtPoint:(CGPoint)point;
- (void)imageHolderDidScroll:(ImageHolder *)holder;
- (void)imageHolderDidEndScroll:(ImageHolder *)holder;

@end



@interface ImageHolder : UIScrollView <UIScrollViewDelegate> {
    
	UIImageView *imageView;
    
}

@property (nonatomic, assign) id<ImageHolderDelegate> holderDelegate;

- (void)setImage:(UIImage *)image;
- (UIImage *)image;
- (UIImage *)getImageWithRect:(CGRect)desiredRect;
- (UIImage*)subImage:(UIImage*)image withRect:(CGRect)rect;

@end