//
//  ImagePickerController.m
//  baby
//
//  Created by zhang da on 14-4-17.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "ImagePickerController.h"


@interface ImagePickerController () {
    NewPictureViewController *picker;
    PictureEditViewController *editor;
}

@end


@implementation ImagePickerController

- (void)dealloc {
    [picker release];
    picker = nil;
    [editor release];
    editor = nil;
    
    self.block = nil;
    [super dealloc];
}

- (id)initWithCallback:(ImagePickCallback)block editable:(bool)editable {
    self = [super init];
    if (self) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];

        self.editable = editable;
        self.block = block;
        
        picker = [[NewPictureViewController alloc] init];
        picker.delegate = self;
        picker.view.frame = CGRectMake(0, 0, 320, screentHeight);
        [self.view addSubview:picker.view];
    }
    return self;
}

- (BOOL)showTopbar {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.view.frame = CGRectMake(0, 0, 320, screentHeight);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma NewPictureViewControllerDelegate
- (void)newImageGet:(UIImage *)image {
    [picker.view removeFromSuperview];
    
    if (self.editable) {
        if (!editor) {
            editor = [[PictureEditViewController alloc] initWithImage:image];
            editor.delegate = self;
        }
        editor.view.frame = CGRectMake(0, 0, 320, screentHeight);
        [self.view addSubview:editor.view];
    } else {
        if (self.block) {
            self.block(image);
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            [ctr popViewControllerAnimated:YES];
        }
    }
}

- (void)cancelImagePick {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [ctr popViewControllerAnimated:YES];
}

- (void)dismissGalleryPicker {
    self.view.frame = CGRectMake(0, 0, 320, screentHeight);
    picker.view.frame = CGRectMake(0, 0, 320, screentHeight);
}



#pragma PictureEditViewControllerDelegate
- (void)pictureFinishEdit:(UIImage *)image {
    [editor.view removeFromSuperview];
    if (self.block) {
        self.block(image);
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [ctr popViewControllerAnimated:YES];
    }
}

- (void)cancelImageEdit {
    [editor.view removeFromSuperview];
    [self.view addSubview:picker.view];
}


@end
