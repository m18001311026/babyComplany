//
//  SharedImagePickerController.m
//  PhotoPicker
//
//  Created by zhangda on 11-4-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SharedImagePickerController.h"

static SharedImagePickerController *sharedImagePickerController = nil;

@implementation SharedImagePickerController

@synthesize imagePickerController;

+ (UIImagePickerController *)sharedImagePicker {
    @synchronized(self) {
        if (sharedImagePickerController == nil) { 
            sharedImagePickerController = [[SharedImagePickerController alloc] init];
        }
    }
    return sharedImagePickerController.imagePickerController;
}

- (id)init {
    self = [super init];
    if (self) {
        imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.allowsEditing = NO;
    }
    return self;
}

- (void)dealloc {
    [imagePickerController release];
    [super dealloc];
}

@end
