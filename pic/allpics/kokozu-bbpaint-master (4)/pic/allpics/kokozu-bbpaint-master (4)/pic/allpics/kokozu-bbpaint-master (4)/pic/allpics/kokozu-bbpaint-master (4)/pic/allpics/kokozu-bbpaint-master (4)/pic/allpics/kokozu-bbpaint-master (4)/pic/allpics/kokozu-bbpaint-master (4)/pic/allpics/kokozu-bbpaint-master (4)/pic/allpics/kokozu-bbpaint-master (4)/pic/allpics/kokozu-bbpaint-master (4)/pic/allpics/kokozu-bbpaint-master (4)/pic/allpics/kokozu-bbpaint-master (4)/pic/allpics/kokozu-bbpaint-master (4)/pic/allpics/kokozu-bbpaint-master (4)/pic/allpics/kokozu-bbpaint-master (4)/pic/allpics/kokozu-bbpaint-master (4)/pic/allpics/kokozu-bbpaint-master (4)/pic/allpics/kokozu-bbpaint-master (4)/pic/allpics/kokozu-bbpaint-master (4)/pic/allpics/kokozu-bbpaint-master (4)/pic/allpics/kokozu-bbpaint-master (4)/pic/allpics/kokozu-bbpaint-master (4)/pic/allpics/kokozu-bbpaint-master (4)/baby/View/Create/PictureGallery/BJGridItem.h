//
//  BJGridItem.h
//  :
//
//  Created by bupo Jung on 12-5-15.
//  Copyright (c) 2012年 Wuxi Smart Sencing Star. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    BJGridItemNormalMode = 0,
    BJGridItemEditingMode = 1,
} BJMode;

@protocol BJGridItemDelegate;

@interface BJGridItem : UIView{
    CGPoint point;//long press point
}

@property(nonatomic, assign) BOOL isEditing;
@property(nonatomic, assign) BOOL isRemovable;
@property(nonatomic, assign) NSInteger index;
@property(nonatomic, assign) id<BJGridItemDelegate> delegate;

- (id)initWithFrame:(CGRect)frame
              title:(NSString *)title
              image:(UIImage *)image
            atIndex:(NSInteger)aIndex
           editable:(BOOL)removable;
- (void)enableEditing;
- (void)disableEditing;
- (void)removeFromSuperviewAnimated;
- (UIImage *)image;
- (void)setImage:(UIImage *)image;

@end


@protocol BJGridItemDelegate <NSObject>
- (void)gridItemDidClicked:(BJGridItem *) gridItem;
- (void)gridItemDidEnterEditingMode:(BJGridItem *) gridItem;
- (void)gridItemDidDeleted:(BJGridItem *) gridItem atIndex:(NSInteger)index;
- (void)gridItemDidMoved:(BJGridItem *) gridItem withLocation:(CGPoint)point moveGestureRecognizer:(UILongPressGestureRecognizer*)recognizer;
- (void)gridItemDidEndMoved:(BJGridItem *) gridItem withLocation:(CGPoint)point moveGestureRecognizer:(UILongPressGestureRecognizer*) recognizer;
@end