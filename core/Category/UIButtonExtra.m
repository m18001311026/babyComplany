//
//  UIButton+UIButtonExtra.m
//  baby
//
//  Created by zhang da on 14-3-4.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "UIButtonExtra.h"

@implementation UIButton (UIButtonExtra)

+ (UIButton *)buttonWithCustomStyle:(CustomButtonStyle)style {
    return [self buttonWithCustomStyle:style position:CustomButtonPositonLeft];
}
+ (UIButton *)buttonWithCustomStyle:(CustomButtonStyle)style position:(CustomButtonPositon)position {
    //点击加号后的Button的位置
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = (position == CustomButtonPositonLeft? CGRectMake(7, 7, 30, 30): CGRectMake(283, 7, 30, 30));
    
    if (style == CustomButtonStyleBack) {
        [button setBackgroundImage:[UIImage imageNamed:@"backWhiteBackground.png"] forState:UIControlStateNormal];
    } else if (style == CustomButtonStyleCancel) {
        [button setBackgroundImage:[UIImage imageNamed:@"mCancel.png"] forState:UIControlStateNormal];
    } else if (style == CustomButtonStyleDone) {
        [button setBackgroundImage:[UIImage imageNamed:@"done_btn.png"] forState:UIControlStateNormal];
    } else if (style == CustomButtonStyleLocation) {
        [button setBackgroundImage:[UIImage imageNamed:@"mLocation.png"] forState:UIControlStateNormal];
    } else if (style == CustomButtonStyleMenu) {
        [button setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
    } else if (style == CustomButtonStyleShare) {
        [button setBackgroundImage:[UIImage imageNamed:@"share_btn.png"] forState:UIControlStateNormal];
    } else if(style == CustomButtonStyleBack2){
        [button setBackgroundImage:[UIImage imageNamed:@"backWord.png"] forState:UIControlStateNormal];
    }
    
    return button;
}

//注册界面
+ (UIButton *)simpleButton:(NSString *)title y:(int)y {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, y, 280, 40);
    [btn setTitle:title forState:UIControlStateNormal];
   // [btn setBackgroundColor:[UIColor orangeColor]];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //验证码
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    
    
    //[btn.layer setCornerRadius:4.0];
    return btn;
}

@end
