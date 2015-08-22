//
//  NewGalleryViewController.h
//  baby
//
//  Created by zhang da on 14-3-10.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBViewController.h"
#import "BUPOView.h"
#import "CreateViewController.h"
#import "VoiceMask.h"

@interface NewGalleryViewController : BBViewController
<UITextViewDelegate, BUPOViewDelegate, CreateViewControllerDelegate> {
    UITextView *introView;
    UILabel *introViewPlaceHolder;
    BUPOView *holder;
    
    UIImageView *showImage;
    UIButton *playbackBtn;
    VoiceMask *voiceMask;
    
    NSMutableDictionary *createViewControllers;
    NSMutableDictionary *imageIds;
}

- (id)initWithGallery:(long)galleryId;

@end
