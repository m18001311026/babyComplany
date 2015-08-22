//
//  TabbarController.h
//  TestWP7View
//
//  Created by alfaromeo on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TabbarSubviewController.h"
#import "TabbarControllerConfig.h"
#import "TabbarItem.h"
#import "NavigationControl.h"


@interface TabbarController : UIViewController
< TabbarSubviewControllerDelegate, TabbarItemDelegate >{
    NSMutableDictionary *viewControllerParams;
    NSMutableDictionary *viewControllerClasses;
    NSMutableDictionary *viewControllers;
    
    UIView *contentView;
    UIImageView *tabbar;
    
    int selectedPage;
    
    struct {
        BOOL disableScroll;
        //防止sub Tabbar controller再初始化时appear函数调用两次
        BOOL initAppear;
    } userFlags;
}

@property (nonatomic, assign) TabbarSubviewController *selectedTabbarSubviewController;
@property (nonatomic, retain) UIImageView *tabbar;
@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, assign) int selectedPage;
@property (nonatomic, assign) ViewSwitchAnimation appearAnimation;

- (id)initWithFrame:(CGRect)frame;
- (void)setViewController:(NSString *)ctrName params:(NSDictionary *)param atIndex:(int)index;
- (void)addItem:(TabbarItem *)item;
- (TabbarItem *)itemAtIndex:(int)idx;
- (void)tabbarItemTouchedAtIndex:(int)index;
- (BOOL)tabbarItemShouldSelectAtIndex:(int)index;

- (void)setTabbarHidden:(BOOL)hide;

//child class override
- (float)tabbarHeight;

- (BOOL)subTabbarShouldScroll;

- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;

- (void)setSelectedPage:(int)value tabBar:(BOOL)exist;
@end
