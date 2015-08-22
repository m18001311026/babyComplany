//
//  CropView.m
//
//  Created by admin on 12-8-15.
//  Copyright (c) 2012年 Xu Yang. All rights reserved.
//

#import "CropView.h"
#import <AssetsLibrary/AssetsLibrary.h>


@implementation CropView

- (void)dealloc {
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame edgeInsets:(UIEdgeInsets)insets frameColor:(UIColor *)color {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        rotateDegree = 0;
        
        imgHolder = [[ImageHolder alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        imgHolder.holderDelegate = self;
        imgHolder.contentInset = insets;
        imgHolder.clipsToBounds = YES;
        [self addSubview:imgHolder];
        [imgHolder release];
        
        overLay = [[UICliper alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)
                                       frameColor:color
                                        responder:imgHolder
                                       edgeInsets:insets];
        [self addSubview:overLay];
        [overLay release];
        
    }
    return self;
}

- (void)setImage:(UIImage *)image{
    [imgHolder setImage:image];
}

- (UIImage *)orginalImage {
    return imgHolder.image;
}

- (void)resetCliper{
    [overLay resetBounds];
}

- (void)croppedImage:(CropCallback)callback {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        @autoreleasepool {
            UIImage *img = [imgHolder getImageWithRect:overLay.clipperFrame];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) {
                    callback(img);
                }
            });
        }
    });
}

- (void)clockRotateImage {
    rotateDegree += M_PI_2;
    if (rotateDegree >= M_PI*2) {
        rotateDegree = 0;
    }
    imgHolder.transform = CGAffineTransformMakeRotation(rotateDegree);
    overLay.transform = CGAffineTransformMakeRotation(rotateDegree);
}

- (void)resetRotate {
    rotateDegree = 0;
    imgHolder.transform = CGAffineTransformIdentity;
    overLay.transform = CGAffineTransformIdentity;
}

- (void)setCliperHidden:(bool)hide {
    overLay.hidden = hide;
}

- (bool)cliperHidden {
    return  overLay.hidden;
}


@end
