//
//  UICliper.h
//
//  Created by Xu Yang on 12-8-14.
//  Copyright (c) 2012年 KoKoZu. All rights reserved.
//

@interface UICliper : UIView {
    
    UIColor *overlayColor;
    
    CGPoint touchPoint, framePoint;
    CGRect clipperFrame;
    
    CGRect availableFrame;
    
    struct {
        int draggingLeft, draggingTop, draggingRight, draggingBottom;
    } clipperFlags;
}

@property (nonatomic, assign) UIView *responder;
@property (nonatomic, assign) CGRect clipperFrame;
@property (nonatomic, retain) UIColor *frameColor;


- (id)initWithFrame:(CGRect)frame
         frameColor:(UIColor *)fColor
          responder:(UIView *)responder
         edgeInsets:(UIEdgeInsets)insets;
- (void)resetBounds;

@end
