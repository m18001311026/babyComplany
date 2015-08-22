//
//  UIButton+UIButtonExtra.h
//  baby
//
//  Created by zhang da on 14-3-4.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CustomButtonStyleDefault = 1,
    CustomButtonStyleTransparent,
    CustomButtonStyleBack,
    CustomButtonStyleBack2,
    CustomButtonStyleMenu,
    CustomButtonStyleShare,
    CustomButtonStyleCancel,
    CustomButtonStyleDone,
    CustomButtonStyleLocation
} CustomButtonStyle;

typedef enum {
    CustomButtonPositonLeft = 1,
    CustomButtonPositonRight
} CustomButtonPositon;

@interface UIButton (UIButtonExtra)

+ (UIButton *)buttonWithCustomStyle:(CustomButtonStyle)style;
+ (UIButton *)buttonWithCustomStyle:(CustomButtonStyle)style position:(CustomButtonPositon)position;

+ (UIButton *)simpleButton:(NSString *)title y:(int)y;

@end
