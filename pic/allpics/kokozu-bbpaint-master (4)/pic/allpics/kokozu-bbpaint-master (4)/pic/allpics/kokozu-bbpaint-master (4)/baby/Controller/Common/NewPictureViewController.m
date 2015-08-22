//
//  NewPictureViewController.m
//  baby
//
//  Created by zhang da on 14-3-10.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "NewPictureViewController.h"
#import "UIButtonExtra.h"
#import "LocalGalleryButton.h"
#import "AVCamView.h"
#import "NewGalleryViewController.h"
#import "PictureEditViewController.h"

#define BOTTOM_HEIGHT 100

@interface NewPictureViewController ()

@end

@implementation NewPictureViewController

- (void)dealloc {
    self.root = nil;
    self.delegate = nil;
    
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor blackColor];
        bbTopbar.backgroundColor = [UIColor blackColor];
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES];

        UIButton *back = [UIButton buttonWithCustomStyle:CustomButtonStyleBack];
        [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [bbTopbar addSubview:back];
        
        flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        flashBtn.frame = CGRectMake(283, 7, 30, 30);
        [flashBtn setImage:[UIImage imageNamed:@"flash_off.png"] forState:UIControlStateNormal];
        [flashBtn addTarget:self action:@selector(toggleFlashMode) forControlEvents:UIControlEventTouchUpInside];
        [bbTopbar addSubview:flashBtn];
        
        camView = [[AVCamView alloc] initWithFrame:CGRectMake(0, 44, 320, screentHeight - BOTTOM_HEIGHT - 44)];
        [self.view addSubview:camView];
        [camView release];
        
        if ([camView cameraCount] > 1) {
            cameraPositionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            cameraPositionBtn.frame = CGRectMake(233, 7, 30, 30);
            [cameraPositionBtn setImage:[UIImage imageNamed:@"camera_toggle.png"] forState:UIControlStateNormal];
            [cameraPositionBtn addTarget:self action:@selector(toggleCamera) forControlEvents:UIControlEventTouchUpInside];
            [bbTopbar addSubview:cameraPositionBtn];
        }
        
        localGalleryBtn = [[LocalGalleryButton alloc] initWithFrame:CGRectMake(255, screentHeight - BOTTOM_HEIGHT + 25, 50, 50)];
        [self.view addSubview:localGalleryBtn];
        [localGalleryBtn addTarget:self action:@selector(chooseGallery) forControlEvents:UIControlEventTouchUpInside];
        [localGalleryBtn release];
        
        captureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        captureBtn.frame = CGRectMake(125, screentHeight - BOTTOM_HEIGHT + 15, 70, 70);
        [captureBtn setImage:[UIImage imageNamed:@"cam_btn"] forState:UIControlStateNormal];
        [captureBtn addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:captureBtn];
        
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            captureBtn.enabled = NO;
            
            UILabel *info = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 20)];
            info.textAlignment = UITextAlignmentCenter;
            info.backgroundColor = [UIColor clearColor];
            info.textColor = [UIColor whiteColor];
            info.font = [UIFont systemFontOfSize:12];
            info.text = @"本设备不支持照相机";
            info.center = CGPointMake(camView.frame.size.width/2, camView.frame.size.height/2);
            [camView addSubview:info];
            [info release];
        }
    }
    return self;
}

- (id)initWithRoot:(NewGalleryViewController *)root {
    self = [self init];
    if (self) {
        self.root = root;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.view.frame = CGRectMake(0, 0, 320, screentHeight);
}


#pragma ui events
- (void)back {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelImagePick)]) {
        [self.delegate cancelImagePick];
    } else {
        [ctr popViewControllerAnimated:YES];
    }
}

- (void)updateButtonStates {
    captureBtn.enabled = ([camView cameraCount] >= 1);
}

- (void)toggleFlashMode {
    switch ([camView flashMode]) {
        case AVCaptureFlashModeAuto:
        case AVCaptureFlashModeOn: {
            [camView setFlashMode:AVCaptureFlashModeOff];
            [flashBtn setImage:[UIImage imageNamed:@"flash_off.png"] forState:UIControlStateNormal];
            break;
        }
        case AVCaptureFlashModeOff: {
            [camView setFlashMode:AVCaptureFlashModeOn];
            [flashBtn setImage:[UIImage imageNamed:@"flash_on.png"] forState:UIControlStateNormal];
            break;
        }
    }

}

- (void)toggleCamera {
    [camView toggleCamera];
}

- (void)takePhoto {
    [camView captureImage:NO callback:^(UIImage *image) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(newImageGet:)]) {
            [self.delegate newImageGet:image];
        } else {
            if ([ctr onTop:self]) {
                PictureEditViewController *pCtr = [[PictureEditViewController alloc] initWithImage:image root:self.root];
                [ctr pushViewController:pCtr animation:ViewSwitchAnimationSwipeR2L];
                [pCtr release];
            }
        }
    }];
}

- (void)chooseGallery {
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        ipc.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        ipc.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:ipc.sourceType];
    }
    ipc.delegate = self;
    ipc.allowsEditing = NO;
    [self presentModalViewController:ipc animated:YES];
    [ipc release];
}


#pragma mark uiimagepickercontroller
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(newImageGet:)]) {
            [self.delegate newImageGet:image];
        } else {
            PictureEditViewController *pCtr = [[PictureEditViewController alloc] initWithImage:image root:self.root];
            [ctr pushViewController:pCtr animation:ViewSwitchAnimationSwipeR2L];
            [pCtr release];
        }
    }
    
    if (iOS7) {
        [picker dismissModalViewControllerAnimated:NO];
        self.view.frame = CGRectMake(0, 20, 320, screentContentHeight);
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    } else {
        [picker dismissModalViewControllerAnimated:YES];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(dismissGalleryPicker)]) {
        [self.delegate dismissGalleryPicker];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (iOS7) {
        [picker dismissModalViewControllerAnimated:NO];
        self.view.frame = CGRectMake(0, 20, 320, screentContentHeight);
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    } else {
        [picker dismissModalViewControllerAnimated:YES];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(dismissGalleryPicker)]) {
        [self.delegate dismissGalleryPicker];
    }
}


@end
