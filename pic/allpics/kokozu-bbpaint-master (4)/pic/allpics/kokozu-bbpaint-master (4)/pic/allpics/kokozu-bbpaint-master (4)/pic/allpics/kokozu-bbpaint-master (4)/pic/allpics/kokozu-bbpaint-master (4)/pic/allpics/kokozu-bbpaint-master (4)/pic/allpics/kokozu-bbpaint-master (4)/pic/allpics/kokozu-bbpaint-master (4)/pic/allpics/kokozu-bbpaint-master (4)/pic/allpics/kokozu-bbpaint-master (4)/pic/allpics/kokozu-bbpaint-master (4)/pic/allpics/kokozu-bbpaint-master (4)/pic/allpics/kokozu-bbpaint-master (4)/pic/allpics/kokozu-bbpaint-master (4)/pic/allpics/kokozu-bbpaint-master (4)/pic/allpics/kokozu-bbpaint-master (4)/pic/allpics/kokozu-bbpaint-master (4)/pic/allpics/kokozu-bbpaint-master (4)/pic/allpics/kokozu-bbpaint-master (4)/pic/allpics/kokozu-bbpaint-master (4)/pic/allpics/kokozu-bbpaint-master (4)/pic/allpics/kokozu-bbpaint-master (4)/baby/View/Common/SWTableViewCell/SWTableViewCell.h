//
//  SWTableViewCell.h
//  SWTableViewCell
//
//  Created by Chris Wendel on 9/10/13.
//  Copyright (c) 2013 Chris Wendel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@class SWTableViewCell;

typedef enum {
    kCellStateCenter,
    kCellStateLeft,
    kCellStateRight
} SWCellState;



@protocol SWTableViewCellDelegate <NSObject>

@optional
- (void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index;
- (void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index;
- (void)swippableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state;

@end



@interface SWTableViewCell : UITableViewCell

@property (nonatomic, retain) NSArray *leftUtilityButtons;
@property (nonatomic, retain) NSArray *rightUtilityButtons;
@property (nonatomic, assign) id <SWTableViewCellDelegate> scrollDelegate;
@property (nonatomic, assign) UIView *scrollViewContentView;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
             height:(CGFloat)height
 leftUtilityButtons:(NSArray *)leftUtilityButtons
rightUtilityButtons:(NSArray *)rightUtilityButtons;

- (void)hideUtilityButtonsAnimated:(BOOL)animated;

@end



@interface NSMutableArray (SWUtilityButtons)

- (void)addUtilityButtonWithColor:(UIColor *)color title:(NSString *)title;
- (void)addUtilityButtonWithColor:(UIColor *)color icon:(UIImage *)icon;

@end
