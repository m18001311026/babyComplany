//
//  UIImageExtra.h
//  baby
//
//  Created by zhang da on 14-3-10.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LocalGalleryImageGot) (UIImage *image);

@interface UIImage (Extra)

+ (void)readLocalLatestPicture:(LocalGalleryImageGot)callback;

- (UIImage*)subImageWithRect:(CGRect)rect backgroundColor:(UIColor *)color;
- (UIImage *)rotatedImage:(CGAffineTransform)trans;

/*
 fill or fit: fill表示填充画布，多余部分裁剪, fit表示适应画布，空白部分留白
 如果finalsize中有长或宽为0，则按照不为0的边缩放，如果长宽均为0，则返回decode的原图
 可以直接在非主线程的decode image，提高主线程绘制性能
 */
- (UIImage *)decodedImageToSize:(CGSize)finalSize fill:(BOOL)fill;

@end
