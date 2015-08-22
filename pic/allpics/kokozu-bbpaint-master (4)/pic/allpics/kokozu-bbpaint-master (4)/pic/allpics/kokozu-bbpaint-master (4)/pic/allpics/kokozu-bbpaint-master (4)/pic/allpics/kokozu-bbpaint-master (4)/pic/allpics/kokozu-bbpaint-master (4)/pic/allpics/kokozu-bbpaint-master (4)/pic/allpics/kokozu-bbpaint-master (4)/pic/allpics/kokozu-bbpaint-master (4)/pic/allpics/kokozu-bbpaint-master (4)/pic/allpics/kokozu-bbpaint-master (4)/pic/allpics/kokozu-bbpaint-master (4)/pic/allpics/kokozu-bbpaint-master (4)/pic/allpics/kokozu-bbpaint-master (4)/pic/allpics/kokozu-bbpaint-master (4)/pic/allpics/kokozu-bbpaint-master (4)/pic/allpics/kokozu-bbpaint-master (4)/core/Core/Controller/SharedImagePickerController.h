//
//  SharedImagePickerController.h
//  PhotoPicker
//
//  Created by zhangda on 11-4-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SharedImagePickerController : NSObject {
    UIImagePickerController *imagePickerController;
}

@property (nonatomic, readonly) UIImagePickerController *imagePickerController;

+ (UIImagePickerController *)sharedImagePicker;

@end


