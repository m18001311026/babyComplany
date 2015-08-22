//
//  IndicatorSegment.h
//  baby
//
//  Created by zhang da on 14-3-17.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IndicatorSegmentDelegate <NSObject>

@optional
- (void)segmentSelected:(NSInteger)index;

@end


@interface IndicatorSegment : UIView {
    NSMutableArray *buttons, *indicators;
}

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) id<IndicatorSegmentDelegate> delegate;

@property (nonatomic, retain) UIColor *selectedColor;
@property (nonatomic, retain) UIColor *normalColor;
@property (nonatomic, retain) UIColor *textColor;

- (id)initWithFrame:(CGRect)frame titles:(NSArray *)titles;
- (UIButton *)segmentAtIndex:(NSInteger)index;
- (void)updateLayout;

@end
