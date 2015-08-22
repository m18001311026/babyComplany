//
//  UIImageButton.h
//  baby
//
//  Created by zhang da on 14-3-6.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageButton : UIControl {

}

@property (nonatomic, retain) UIImageView *icon;
@property (nonatomic, retain) UILabel *text;

@property (nonatomic, retain) UIColor *textNormalColor;
@property (nonatomic, retain) UIColor *textHighlightedColor;
@property (nonatomic, retain) UIColor *textSelectedColor;
@property (nonatomic, assign) int imageHeight;

- (id)initWithFrame:(CGRect)frame
              image:(NSString *)imageName
        imageHeight:(int)imageHeight
               text:(NSString *)text
           fontSize:(int)fontSize;
- (void)setImage:(UIImage *)image;
- (void)centerContent;

@end
