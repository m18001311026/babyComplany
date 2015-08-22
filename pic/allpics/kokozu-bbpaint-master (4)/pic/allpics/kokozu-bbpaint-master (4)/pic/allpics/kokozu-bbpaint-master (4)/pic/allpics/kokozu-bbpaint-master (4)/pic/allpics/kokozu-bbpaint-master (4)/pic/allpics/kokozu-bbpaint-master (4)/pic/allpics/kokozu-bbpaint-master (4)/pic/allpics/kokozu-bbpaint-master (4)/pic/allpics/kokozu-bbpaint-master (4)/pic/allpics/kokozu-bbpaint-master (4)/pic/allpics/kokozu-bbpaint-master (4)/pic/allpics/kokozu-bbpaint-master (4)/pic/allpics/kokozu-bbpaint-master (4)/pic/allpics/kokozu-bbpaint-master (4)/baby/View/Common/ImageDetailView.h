//
//  ImageDetailView.h
//  baby
//
//  Created by zhang da on 14-4-2.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageDetailView : UIView <UIScrollViewDelegate> {
    UIScrollView *holder;
	UIImageView *imageView;
    UIActivityIndicatorView *indicator;
}

- (void)setImagePath:(NSString *)imagePath;
//- (void)setImage:(UIImage *)image;
- (UIImage *)image;

@end
