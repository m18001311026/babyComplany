//
//  ImageView.h
//  baby
//
//  Created by zhang da on 14-3-17.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageView : UIImageView {
    UIActivityIndicatorView *indicator;
    UILabel *imageUrl;
}

@property (nonatomic, retain) NSString *imagePath;

- (void)setImagePath:(NSString *)imagePath done:(void (^)())block;

@end
