//
//  GalleryCell.h
//  baby
//
//  Created by zhang da on 14-3-4.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageView;

@interface HorizonMaterialCell : UIView {
    ImageView *pictureView;
}

@property (nonatomic, retain) NSString *picturePath;

- (void)updateLayout;

@end
