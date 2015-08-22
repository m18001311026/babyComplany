//
//  KKZViewController.h
//  KKZ
//
//  Created by alfaromeo on 12-3-9.
//  Copyright (c) 2012年 kokozu. All rights reserved.
//

#import "NavigationControl.h"

@interface BBViewController : UIViewController {    
    UILabel *bbTitleLabel;
    UIView *bbTopbar;
    
    struct {
        BOOL initAppear;
    } userFlags;
}

@property (nonatomic, assign) ViewSwitchAnimation appearAnimation;

- (BOOL)showTopbar;
- (void)setViewTitle:(NSString *)viewTitle;
- (void)setTopbarHeight:(float)height;

@end
