//
//  PictureThumbView.h
//  baby
//
//  Created by zhang da on 14-3-10.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureThumbView : UIView {

    UIImageView *pictureThumb;

}

@property (nonatomic, retain) NSString *voiceFile;

- (void)setImage:(UIImage *)image;

@end
