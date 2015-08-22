//
//  PictureEditViewController.m
//  baby
//
//  Created by zhang da on 14-3-10.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "PictureEditViewController.h"
#import "CropView.h"
#import "UIButtonExtra.h"
#import "NewGalleryViewController.h"
#import "ImageFilter.h"


#define BOTTOM_HEIGHT 100

@interface PictureEditViewController ()

@property (nonatomic, assign) bool isProcessing;

@end

@implementation PictureEditViewController

- (void)setMode:(EditMode)mode {
    if (_mode != mode) {
        if (mode == EditModeRotate) {
            [cropper setCliperHidden:YES];
            [self dismissFilterView];
        } else if (mode == EditModeCrop) {
            [cropper setCliperHidden:NO];
            [self dismissFilterView];
        } else if (mode == EditModeFilter) {
            [cropper setCliperHidden:YES];
            [self showFilterView];
        }
        _mode = mode;
    }
}

- (void)setIsProcessing:(bool)isProcessing {
    if (_isProcessing != isProcessing) {
        _isProcessing = isProcessing;
        if (isProcessing) {
            [UI showIndicator];
        } else {
            [UI hideIndicator];
        }
    }
}

- (void)dealloc {
    self.orginImage = nil;
    self.filterImage = nil;
    self.basicImage = nil;
    self.delegate = nil;
    
    [imageFilterView release];
    
    [super dealloc];
}

- (id)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.orginImage = image;
        
        cropper = [[CropView alloc] initWithFrame:CGRectMake(0, 44, 320, screentContentHeight - BOTTOM_HEIGHT - 44)
                                       edgeInsets:UIEdgeInsetsMake(30, 30, 30, 30)
                                       frameColor:[UIColor whiteColor]];
        cropper.backgroundColor = [UIColor blackColor];
        [cropper setCliperHidden:YES];
        [self.view addSubview:cropper];
        [cropper release];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image root:(NewGalleryViewController *)root {
    self = [self initWithImage:image];
    if (self) {
        self.root = root;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    bbTopbar.backgroundColor = [UIColor blackColor];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    UIButton *back = [UIButton buttonWithCustomStyle:CustomButtonStyleBack];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [bbTopbar addSubview:back];
    
    UIButton *doneBtn = [UIButton buttonWithCustomStyle:CustomButtonStyleDone];
    doneBtn.frame = CGRectMake(284, 7, 30, 30);
    [doneBtn addTarget:self action:@selector(finishEditing) forControlEvents:UIControlEventTouchUpInside];
    [bbTopbar addSubview:doneBtn];
    
    UIButton *rotateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rotateBtn setImage:[UIImage imageNamed:@"rotate_btn"] forState:UIControlStateNormal];
    rotateBtn.frame = CGRectMake(15, screentHeight - 85, 70, 70);
    [rotateBtn addTarget:self action:@selector(toggleRotate) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rotateBtn];
    
    UIButton *cropBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cropBtn setImage:[UIImage imageNamed:@"crop_btn"] forState:UIControlStateNormal];
    cropBtn.frame = CGRectMake(125, screentHeight - 85, 70, 70);
    [cropBtn addTarget:self action:@selector(toggleCrop) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cropBtn];
    
    UIButton *filterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [filterBtn setImage:[UIImage imageNamed:@"filter_btn"] forState:UIControlStateNormal];
    filterBtn.frame = CGRectMake(235, screentHeight - 85, 70, 70);
    [filterBtn addTarget:self action:@selector(toggleFilter) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:filterBtn];
    
    if (self.orginImage) {
        [UI showIndicator];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.orginImage) {
        [cropper setImage:self.orginImage];
        [UI hideIndicator];
    }
    
    self.view.frame = CGRectMake(0, 0, 320, screentHeight);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark utility
- (void)showFilterView {
    if (!imageFilterView) {
        imageFilterView = [[UIView alloc] initWithFrame:
                           CGRectMake(0, screentHeight - BOTTOM_HEIGHT, 320, BOTTOM_HEIGHT)];
        imageFilterView.backgroundColor = [UIColor blackColor];
        
        UILabel *sLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, 90, 16)];
        sLb.textAlignment = UITextAlignmentCenter;
        sLb.backgroundColor = [UIColor clearColor];
        sLb.textColor = [UIColor whiteColor];
        sLb.font = [UIFont systemFontOfSize:12];
        sLb.text = @"饱和度";
        [imageFilterView addSubview:sLb];
        [sLb release];
        
        saturateSlider = [[UISlider alloc] initWithFrame:CGRectMake(90, 10, 200, 16)];
        [imageFilterView addSubview:saturateSlider];
        [saturateSlider setThumbImage:[UIImage imageNamed:@"slider_bar"] forState:UIControlStateNormal];
        [saturateSlider setThumbImage:[UIImage imageNamed:@"slider_bar"] forState:UIControlStateHighlighted];
        [saturateSlider setMinimumTrackImage:[UIImage imageNamed:@"slider_left"] forState:UIControlStateNormal];
        [saturateSlider setMaximumTrackImage:[UIImage imageNamed:@"slider_right"] forState:UIControlStateNormal];
        saturateSlider.minimumValue = 0;
        saturateSlider.maximumValue = 10;
        saturateSlider.continuous = NO;
        saturateSlider.value = 5;
        [saturateSlider addTarget:self action:@selector(slide:) forControlEvents:UIControlEventValueChanged];
        [saturateSlider release];
        
        UILabel *bLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 42, 90, 16)];
        bLb.textAlignment = UITextAlignmentCenter;
        bLb.backgroundColor = [UIColor clearColor];
        bLb.textColor = [UIColor whiteColor];
        bLb.font = [UIFont systemFontOfSize:12];
        bLb.text = @"亮度";
        [imageFilterView addSubview:bLb];
        [bLb release];
        
        brightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(90, 40, 200, 16)];
        [imageFilterView addSubview:brightnessSlider];
        [brightnessSlider setThumbImage:[UIImage imageNamed:@"slider_bar"] forState:UIControlStateNormal];
        [brightnessSlider setThumbImage:[UIImage imageNamed:@"slider_bar"] forState:UIControlStateHighlighted];
        [brightnessSlider setMinimumTrackImage:[UIImage imageNamed:@"slider_left"] forState:UIControlStateNormal];
        [brightnessSlider setMaximumTrackImage:[UIImage imageNamed:@"slider_right"] forState:UIControlStateNormal];
        brightnessSlider.minimumValue = 0;
        brightnessSlider.maximumValue = 10;
        brightnessSlider.value = 5;
        brightnessSlider.continuous = NO;
        [brightnessSlider addTarget:self action:@selector(slide:) forControlEvents:UIControlEventValueChanged];
        [brightnessSlider release];

        UILabel *cLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 72, 90, 16)];
        cLb.textAlignment = UITextAlignmentCenter;
        cLb.backgroundColor = [UIColor clearColor];
        cLb.textColor = [UIColor whiteColor];
        cLb.font = [UIFont systemFontOfSize:12];
        cLb.text = @"对比度";
        [imageFilterView addSubview:cLb];
        [cLb release];
        
        contrastSlider = [[UISlider alloc] initWithFrame:CGRectMake(90, 70, 200, 16)];
        [imageFilterView addSubview:contrastSlider];
        [contrastSlider setThumbImage:[UIImage imageNamed:@"slider_bar"] forState:UIControlStateNormal];
        [contrastSlider setThumbImage:[UIImage imageNamed:@"slider_bar"] forState:UIControlStateHighlighted];
        [contrastSlider setMinimumTrackImage:[UIImage imageNamed:@"slider_left"] forState:UIControlStateNormal];
        [contrastSlider setMaximumTrackImage:[UIImage imageNamed:@"slider_right"] forState:UIControlStateNormal];
        contrastSlider.minimumValue = 0;
        contrastSlider.maximumValue = 10;
        contrastSlider.value = 5;
        contrastSlider.continuous = NO;
        [contrastSlider addTarget:self action:@selector(slide:) forControlEvents:UIControlEventValueChanged];
        [contrastSlider release];
    }
    
    [self.view addSubview:imageFilterView];
}

- (void)dismissFilterView {
    if ([imageFilterView superview]) {
        [imageFilterView removeFromSuperview];
    }
}


#pragma ui events
- (void)back {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelImageEdit)]) {
        [self.delegate cancelImageEdit];
    } else {
        [ctr popViewControllerAnimated:YES];
    }
}

- (void)toggleCrop {
    if (self.mode != EditModeCrop) {
        self.mode = EditModeCrop;
    } else {
        self.mode = EditModeRotate;
    }
}

- (void)toggleRotate {
    if (self.mode != EditModeRotate) {
        self.mode = EditModeRotate;
    } else {
        [cropper clockRotateImage];
    }
}

- (void)toggleFilter {
    if (self.mode != EditModeFilter) {
        self.mode = EditModeFilter;
    } else {
        self.mode = EditModeRotate;
    }
}

- (void)slide:(UISlider *)slider {
    NSLog(@"%f", slider.value/5.0f);
    
    if (!self.filterImage) {
        self.filterImage = self.orginImage;
    }
    
    if (preSlider != slider) {
        if (!preSlider) {
            self.basicImage = self.orginImage;
        } else {
            self.basicImage = self.filterImage;
        }
    }

    if (slider == saturateSlider) {
        self.filterImage = [self.basicImage saturate:slider.value/5.0f];
    } else if (slider == brightnessSlider) {
        self.filterImage = [self.basicImage brightness:slider.value/5.0f];
    } else if (slider == contrastSlider) {
        self.filterImage = [self.basicImage contrast:slider.value/5.0f];
    }
    
    preSlider = slider;
    [cropper setImage:self.filterImage];
}

- (void)finishEditing {
    if (self.isProcessing) {
        return;
    }
    
    if (self.mode == EditModeRotate) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pictureFinishEdit:)]) {
            [self.delegate pictureFinishEdit:cropper.orginalImage];
        } else {
//            AddVoiceViewController *vCtr = [[AddVoiceViewController alloc] initWithImage:cropper.orginalImage root:self.root];
//            [ctr pushViewController:vCtr animation:ViewSwitchAnimationSwipeR2L];
//            [vCtr release];
        }
    } else if (self.mode == EditModeCrop) {
        self.mode = EditModeRotate;
        self.isProcessing = YES;
        [cropper croppedImage:^(UIImage *image) {
            //if ([ctr onTop:self]) {
                [cropper resetRotate];
                [cropper setImage:image];
                self.isProcessing = NO;
            //}
        }];
    } else if (self.mode == EditModeFilter) {
        self.mode = EditModeRotate;

        [self dismissFilterView];
    }
}


@end
