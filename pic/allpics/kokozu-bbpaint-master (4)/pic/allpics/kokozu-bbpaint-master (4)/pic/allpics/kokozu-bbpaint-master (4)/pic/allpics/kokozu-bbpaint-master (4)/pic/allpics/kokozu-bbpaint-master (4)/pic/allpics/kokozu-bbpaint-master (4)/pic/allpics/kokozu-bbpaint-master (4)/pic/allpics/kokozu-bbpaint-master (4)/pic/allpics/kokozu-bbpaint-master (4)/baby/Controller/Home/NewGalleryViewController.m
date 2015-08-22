//
//  NewGalleryViewController.m
//  baby
//
//  Created by zhang da on 14-3-10.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "NewGalleryViewController.h"
#import "UIButtonExtra.h"
#import "Picture.h"
#import "PostTask.h"
#import "TaskQueue.h"

#import "AudioRecorder.h"
#import "AudioPlayer.h"

#define PICTURE_WIDTH 80
#define PICTURE_MARGIN 10
#define PLACE_HOLDER @"点击添加介绍..."


@interface NewGalleryViewController()

@property (nonatomic, assign) long galleryId;
@property (nonatomic, assign) BOOL isUploading;
@end


@implementation NewGalleryViewController

- (void)dealloc {
    [createViewControllers release];
    [imageIds release];
    
    [super dealloc];
}

- (id)initWithGallery:(long)galleryId {
    self = [super init];
    if (self) {
        // Initialization code
        UIView *introBgView = [[UIView alloc] initWithFrame:CGRectMake(10, 54, 300, 120)];
        [self.view addSubview:introBgView];
        introBgView.backgroundColor = [Shared bbWhite];
        [introBgView release];

        introView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 90)];
        introView.backgroundColor = [UIColor clearColor];
        introView.delegate = self;
        introView.backgroundColor = [UIColor clearColor];
        introView.font = [UIFont systemFontOfSize:15];
        [introBgView addSubview:introView];
        [introView release];

        introViewPlaceHolder = [[UILabel alloc] initWithFrame:CGRectMake(8, 10, 284, 13)];
        introViewPlaceHolder.font = [UIFont systemFontOfSize:15];
        introViewPlaceHolder.backgroundColor = [UIColor clearColor];
        introViewPlaceHolder.textColor = [UIColor grayColor];
        introViewPlaceHolder.text = PLACE_HOLDER;
        introViewPlaceHolder.userInteractionEnabled = NO;
        [introBgView addSubview:introViewPlaceHolder];
        [introViewPlaceHolder release];

        holder = [[BUPOView alloc] initWithFrame:CGRectMake(0, 174, 320, 166)];
        holder.backgroundColor = [UIColor clearColor];
        holder.delegate = self;
        [self.view addSubview:holder];
        [holder release];
        
        UIButton *done = [UIButton buttonWithType:UIButtonTypeCustom];
        done.frame = CGRectMake(260, 9, 50, 30);
        [done setTitle:@"发 表" forState:UIControlStateNormal];
        [done setTitleColor:[UIColor colorWithRed:236/225.0 green:151/225.0 blue:32/225.0 alpha:1.0] forState:UIControlStateNormal];
        [done addTarget:self action:@selector(postGallery) forControlEvents:UIControlEventTouchUpInside];
        [bbTopbar addSubview:done];
        
        playbackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        playbackBtn.frame = CGRectMake(255, screentHeight - 70, 40, 40);
        [playbackBtn setTitle:@"回放" forState:UIControlStateNormal];
        [playbackBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [playbackBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateDisabled];
        [playbackBtn addTarget:self action:@selector(playback) forControlEvents:UIControlEventTouchUpInside];
        playbackBtn.layer.borderColor = [UIColor orangeColor].CGColor;
        playbackBtn.layer.cornerRadius = 2;
        playbackBtn.layer.borderWidth = 1;
        playbackBtn.layer.masksToBounds = YES;
        [self.view addSubview:playbackBtn];
        
        voiceMask = [[VoiceMask alloc] initWithFrame:CGRectMake(0, 0, 320, screentContentHeight)];
        
        UIButton *voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        voiceBtn.frame = CGRectMake(140, screentHeight - 65, 20, 35);
        [voiceBtn setImage:[UIImage imageNamed:@"speak.png"] forState:UIControlStateNormal];
        [voiceBtn addTarget:self action:@selector(startRecord) forControlEvents:UIControlEventTouchDown];
        [voiceBtn addTarget:self action:@selector(stopRecord)
           forControlEvents: UIControlEventTouchUpInside|UIControlEventTouchCancel];
        [voiceBtn addTarget:self action:@selector(cancelRecord) forControlEvents: UIControlEventTouchUpOutside];
        [self.view addSubview:voiceBtn];
        
        _galleryId = galleryId;
        createViewControllers = [[NSMutableDictionary alloc] init];
        imageIds = [[NSMutableDictionary alloc] init];
        [AudioRecorder reset];
        
        [self initHolderWithGallery:galleryId];
        
        delegate.window.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setViewTitle:@"编辑"];
   // bbTopbar.backgroundColor = [UIColor grayColor];
    
    UIButton *back = [UIButton buttonWithCustomStyle:CustomButtonStyleBack];
    [back setImage:[UIImage imageNamed:@"backWhitebackground.png"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [bbTopbar addSubview:back];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


#pragma mark utility
- (void)initHolderWithGallery:(long)galleryId {
    NSArray *pics = [Picture getPicturesForGallery:galleryId];
    if (pics.count) {
        for (Picture *pic in pics) {
            [IMG getImage:pic.imageBig
                 callback:^(NSString *url, UIImage *image) {
                     [holder addImage:image];
                 }];
        }
    }
}


#pragma mark ui event
- (void)back {
    [ctr popViewControllerAnimated:YES];
}

- (void)postGallery {
    if (self.isUploading) {
        [UI showAlert:@"上传中，稍等"];
        return;
    } else {
        self.isUploading = YES;
    }
    
    [UI showIndicator];
    
    
    NSTimeInterval length = [AudioRecorder voiceLength];
    NSData *mp3 = nil;
    if (length > 0) {
        mp3 = [AudioRecorder dumpMP3];
    }
    
    NSArray *pictureList = [holder images];
    PostTask *task = [[PostTask alloc] initNewGallery:pictureList
                                              content:introView.text
                                                voice:mp3
                                               length:length
                                                   re:self.galleryId];
    task.logicCallbackBlock = ^(bool succeeded, id userInfo) {
        [UI hideIndicator];
        self.isUploading = NO;

        if (succeeded) {
            [UI showAlert:@"图片集添加成功"];
            
//            Picture *cover = nil;
//            if (pictureList && pictureList.count > 0) {
//                Picture *pic = [pictureList objectAtIndex:0];
//                cover = [Picture getPictureWithId:pic._id];
//            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_NEWGALLERYADD object:nil];
            [ctr popToRootViewControllerWithAnimation:ViewSwitchAnimationBounce];
            
//            long galleryId = [[userInfo objectForKey:@"galleryId"] longValue];
        }
    };
    [TaskQueue addTaskToQueue:task];
    [task release];
}


#pragma mark uitextfield delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    if ([textView.text length] + [text length] - range.length == 0 ){
        introViewPlaceHolder.text = PLACE_HOLDER;
    } else {
        introViewPlaceHolder.text = @"";
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (!largeScreen) {
        self.view.center = CGPointMake(160, 180);
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (!largeScreen) {
        self.view.center = CGPointMake(160, 20 + screentContentHeight/2);
    }
    return YES;
}



#pragma mark BUPOViewDelegate
- (void)addButtonTouched {
    [introView resignFirstResponder];
    
    CreateViewController *cCtr = [[CreateViewController alloc] initWithDelegate:self
                                                                     background:nil
                                                                          index:-1];
    [ctr pushViewController:cCtr animation:ViewSwitchAnimationBounce];
}

- (void)touchedAtImage:(UIImage *)image index:(NSInteger)index {
    CreateViewController *cCtr = nil;
    
    NSArray *ids = [imageIds allKeys];
    for (NSString *iId in ids) {
        if ([imageIds objectForKey:iId] == image) {
            cCtr = [createViewControllers objectForKey:iId];
            cCtr.index = index;
        }
    }
    if (!cCtr) {
        cCtr = [[CreateViewController alloc] initWithDelegate:self background:image index:index];
        NSString *uuid = [[NSProcessInfo processInfo] globallyUniqueString];
        [imageIds setObject:image forKey:uuid];
        [createViewControllers setObject:cCtr forKey:uuid];
        [cCtr release];
    }
    
    [ctr pushViewController:cCtr animation:ViewSwitchAnimationBounce];
}


#pragma mark CreateViewControllerDelegate
- (void)newImageAdd:(UIImage *)image from:(CreateViewController *)theCtr originalIndex:(NSInteger)index {
    if (image) {
        if (index == -1) {
            //new image
            NSString *uuid = [[NSProcessInfo processInfo] globallyUniqueString];
            [imageIds setObject:image forKey:uuid];
            [createViewControllers setObject:theCtr forKey:uuid];
            [holder addImage:image];
        } else {
            //current image
            NSArray *ids = [createViewControllers allKeys];
            for (NSString *iId in ids) {
                if ([createViewControllers objectForKey:iId] == theCtr) {
                    [imageIds setObject:image forKey:iId];
                }
            }
            [holder setImage:image forIndex:index];
        }
    }
}


#pragma record
- (void)startRecord {
    [AudioPlayer stopPlay];
    
    playbackBtn.enabled = YES;
    [AudioRecorder startRecord];
    [delegate.window addSubview:voiceMask];
    [voiceMask startAnimation];
}

- (void)stopRecord {
    playbackBtn.enabled = YES;
    [AudioRecorder stopRecord];
    [voiceMask removeFromSuperview];
    [voiceMask stopAnimation];
}

- (void)cancelRecord {
    playbackBtn.enabled = YES;
    [AudioRecorder stopRecord];
    [voiceMask removeFromSuperview];
    [voiceMask stopAnimation];
}

- (void)playback {
    [AudioPlayer startPlayFile:[AudioRecorder cafFile] finished:^{
        
    }];
}


@end
