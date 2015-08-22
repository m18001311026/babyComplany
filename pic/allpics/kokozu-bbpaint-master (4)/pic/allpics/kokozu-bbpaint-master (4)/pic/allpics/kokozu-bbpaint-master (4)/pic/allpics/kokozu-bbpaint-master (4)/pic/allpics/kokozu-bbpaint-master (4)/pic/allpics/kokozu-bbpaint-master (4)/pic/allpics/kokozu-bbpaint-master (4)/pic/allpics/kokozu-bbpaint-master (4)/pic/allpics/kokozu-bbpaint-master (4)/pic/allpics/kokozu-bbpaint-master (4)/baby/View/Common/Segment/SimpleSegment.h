//
//  SimpleSegment.h
//  baby
//
//  Created by zhang da on 14-3-17.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SimpleSegmentDelegate <NSObject>

@optional
- (void)segmentSelected:(NSInteger)index;

@end


@interface SimpleSegment : UIView {
    NSMutableArray *buttons;
    UIView *holder;
}

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) id<SimpleSegmentDelegate> delegate;

@property (nonatomic, retain) UIColor *selectedBackgoundColor;
@property (nonatomic, retain) UIColor *normalBackgroundColor;
@property (nonatomic, retain) UIColor *selectedTextColor;
@property (nonatomic, retain) UIColor *normalTextColor;

@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic, assign) int borderWidth;

- (id)initWithFrame:(CGRect)frame titles:(NSArray *)titles borderWidth:(int)width;
- (UIButton *)segmentAtIndex:(NSInteger)index;
- (void)updateLayout;

@end
