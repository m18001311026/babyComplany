//
//  BUPOViewController.h
//  ZakerLike
//
//  Created by bupo Jung on 12-5-15.
//  Copyright (c) 2012年 Wuxi Smart Sencing Star. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "BJGridItem.h"


@protocol BUPOViewDelegate <NSObject>

@required
- (void)addButtonTouched;
- (void)touchedAtImage:(UIImage *)image index:(NSInteger)index;
@end


@interface BUPOView : UIView < UIScrollViewDelegate, BJGridItemDelegate, UIGestureRecognizerDelegate > {
    
    NSMutableArray *gridItems;
    BJGridItem *addbutton;
    int page;
    float preX;
    BOOL isMoving;
    CGRect preFrame;
    BOOL isEditing;
    UITapGestureRecognizer *singletap;

}

@property (nonatomic, assign) id<BUPOViewDelegate> delegate;
@property (nonatomic, retain) UIScrollView *scrollview;

- (void)addImage:(UIImage *)image;
- (void)setImage:(UIImage *)image forIndex:(NSInteger)index;
- (NSArray *)images;

@end
