//
//  ImagePickerController.h
//  baby
//
//  Created by zhang da on 14-4-17.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "BBViewController.h"
#import "NewPictureViewController.h"
#import "PictureEditViewController.h"


typedef void ( ^ImagePickCallback )(UIImage *image);


@interface ImagePickerController : BBViewController
<NewPictureViewControllerDelegate, PictureEditViewControllerDelegate>

@property (nonatomic, copy) ImagePickCallback block;
@property (nonatomic, assign) bool editable;

- (id)initWithCallback:(ImagePickCallback)block editable:(bool)editable;


@end
