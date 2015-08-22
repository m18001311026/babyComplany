//
//  PictureEditViewController.h
//  baby
//
//  Created by zhang da on 14-3-10.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "BBViewController.h"

typedef enum {
    EditModeRotate = 0,
    EditModeCrop = 1,
    EditModeFilter = 2
} EditMode;

@class CropView;
@class NewGalleryViewController;


@protocol PictureEditViewControllerDelegate <NSObject>

@optional
- (void)pictureFinishEdit:(UIImage *)image;
- (void)cancelImageEdit;
@end


@interface PictureEditViewController : BBViewController {
    CropView *cropper;
    UIView *imageFilterView;
    UISlider *brightnessSlider, *contrastSlider, *saturateSlider, *preSlider;
}

@property (nonatomic, assign) id<PictureEditViewControllerDelegate> delegate;
@property (nonatomic, assign) NewGalleryViewController *root;
@property (nonatomic, assign) EditMode mode;
@property (nonatomic, retain) UIImage *orginImage;
@property (nonatomic, retain) UIImage *filterImage;
@property (nonatomic, retain) UIImage *basicImage;


- (id)initWithImage:(UIImage *)image;
- (id)initWithImage:(UIImage *)image root:(NewGalleryViewController *)root;

@end
