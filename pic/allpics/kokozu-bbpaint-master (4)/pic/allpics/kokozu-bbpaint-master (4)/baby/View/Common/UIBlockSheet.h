//
//  UIBlockSheet.h
//  baby
//
//  Created by zhang da on 14-6-2.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBlockSheet : UIView <UIActionSheetDelegate> {
@private
    UIActionSheet *_sheet;
    NSMutableArray *_blocks;
}

- (id)initWithTitle:(NSString *)title;
- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block;
- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block;
- (void)showInView:(UIView *)view;

@end
