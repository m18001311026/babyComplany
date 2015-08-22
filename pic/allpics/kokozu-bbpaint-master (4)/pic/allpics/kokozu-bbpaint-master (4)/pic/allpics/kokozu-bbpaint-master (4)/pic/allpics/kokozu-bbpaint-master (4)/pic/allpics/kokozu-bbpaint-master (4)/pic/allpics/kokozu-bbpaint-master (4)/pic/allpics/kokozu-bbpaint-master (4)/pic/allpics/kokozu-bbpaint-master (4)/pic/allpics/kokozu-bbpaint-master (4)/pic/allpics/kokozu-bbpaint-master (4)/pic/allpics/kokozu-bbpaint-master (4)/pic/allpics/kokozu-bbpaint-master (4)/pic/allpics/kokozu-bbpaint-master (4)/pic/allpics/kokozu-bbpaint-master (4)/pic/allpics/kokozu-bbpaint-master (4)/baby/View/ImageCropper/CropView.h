//
//  CropView.h
//
//  Created by admin on 12-8-15.
//  Copyright (c) 2012年 Xu Yang. All rights reserved.
//

#import "ImageHolder.h"
#import "UICliper.h"

typedef void (^CropCallback) (UIImage *image);

@interface CropView : UIView < ImageHolderDelegate > {
    ImageHolder *imgHolder;
    UICliper *overLay;
    CGFloat rotateDegree;
}

- (id)initWithFrame:(CGRect)frame edgeInsets:(UIEdgeInsets)insets frameColor:(UIColor *)color;

- (void)setImage:(UIImage *)image;
- (UIImage *)orginalImage;
- (void)resetCliper;
- (void)croppedImage:(CropCallback)callback;

- (void)setCliperHidden:(bool)hide;
- (bool)cliperHidden;

- (void)clockRotateImage;
- (void)resetRotate;

@end
