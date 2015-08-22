//
//  NewPictureViewController.h
//  baby
//
//  Created by zhang da on 14-3-10.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "BBViewController.h"

@class LocalGalleryButton;
@class NewGalleryViewController;
@class AVCamView;

@protocol NewPictureViewControllerDelegate <NSObject>

@optional
- (void)newImageGet:(UIImage *)image;
- (void)cancelImagePick;
- (void)dismissGalleryPicker;
@end


@interface NewPictureViewController : BBViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate>{

    UIButton *flashBtn, *captureBtn, *cameraPositionBtn;
    LocalGalleryButton *localGalleryBtn;
    AVCamView *camView;
}

@property (nonatomic, assign) id<NewPictureViewControllerDelegate> delegate;
@property (nonatomic, assign) NewGalleryViewController *root;

- (id)initWithRoot:(NewGalleryViewController *)root;

@end
