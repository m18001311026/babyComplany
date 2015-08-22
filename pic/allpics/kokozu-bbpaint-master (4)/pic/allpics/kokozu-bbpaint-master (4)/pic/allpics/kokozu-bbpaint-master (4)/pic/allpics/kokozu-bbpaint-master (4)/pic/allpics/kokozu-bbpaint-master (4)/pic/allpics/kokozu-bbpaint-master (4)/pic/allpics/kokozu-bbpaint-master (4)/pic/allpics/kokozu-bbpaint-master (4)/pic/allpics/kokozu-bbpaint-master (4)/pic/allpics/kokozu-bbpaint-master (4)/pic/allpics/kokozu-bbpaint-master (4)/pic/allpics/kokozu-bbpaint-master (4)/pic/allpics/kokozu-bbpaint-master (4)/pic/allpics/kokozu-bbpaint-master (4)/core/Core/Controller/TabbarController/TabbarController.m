//
//  TabbarController.m
//  TestWP7View
//
//  Created by alfaromeo on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TabbarController.h"
#import "TaskQueue.h"

@interface TabbarController ()

- (TabbarSubviewController *)viewControllerAtIndex:(int)index;

@end


@implementation TabbarController

@synthesize contentView, tabbar, selectedPage;
@synthesize selectedTabbarSubviewController;
@synthesize appearAnimation;

- (void)dealloc {
    self.selectedTabbarSubviewController.parentController = nil;
    self.selectedTabbarSubviewController = nil;
    
    [viewControllerClasses release];
    [viewControllerParams release];
    [viewControllers release];
    
    [contentView release];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super init];
    if (self) {
        selectedPage = 0;
        userFlags.initAppear = YES;
        
        contentView = [[UIView alloc] initWithFrame:frame];
        contentView.backgroundColor = [UIColor clearColor];
        
        viewControllerClasses = [[NSMutableDictionary alloc] init];
        viewControllerParams = [[NSMutableDictionary alloc] init];
        viewControllers = [[NSMutableDictionary alloc] init];
                
        tabbar = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                          frame.size.height - [self tabbarHeight],
                                                          frame.size.width,
                                                          [self tabbarHeight])];
        tabbar.userInteractionEnabled = YES;
        tabbar.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:tabbar];
        [tabbar release];
    }
    return self;

}

- (void)setSelectedPage:(int)value {
#if DEBUG_TABBARCONTROLLER
    NSLog(@"new page :%d", value);
#endif
    if ( value != selectedPage  && !userFlags.disableScroll ) {
        
        BOOL right = (selectedPage > value);
        TabbarSubviewController *newCtr = [self viewControllerAtIndex:value];
        if (newCtr) {
            CGRect newCtrFrame = contentView.frame;
            newCtrFrame.origin = CGPointZero;
            CGRect newCtrDstFrame = newCtrFrame, currentCtrDstFrame = newCtrFrame;
            
            if (right) {
                newCtrFrame.origin.x -= newCtrFrame.size.width;
                newCtr.view.frame = newCtrFrame;
                currentCtrDstFrame.origin.x += newCtrFrame.size.width;
            } else {
                newCtrFrame.origin.x += newCtrFrame.size.width;
                newCtr.view.frame = newCtrFrame;
                currentCtrDstFrame.origin.x -= newCtrFrame.size.width;

            }
            
            [contentView insertSubview:newCtr.view belowSubview:tabbar];
         

#if DEBUG_TABBARCONTROLLER
            DLog(@"old:%@ new:%@", selectedTabbarSubviewController, newCtr);
#endif
        
            [UIView animateWithDuration:.6
                             animations:^{
                                 userFlags.disableScroll = YES;
                 
                                 TabbarItem *current = [self itemAtIndex:selectedPage];
                                 current.activated = NO;
                                 
                                 self.selectedTabbarSubviewController.view.frame = currentCtrDstFrame;
                                 newCtr.view.frame = newCtrDstFrame;
                             }
                             completion:^(BOOL finished) {
                 
                                 [self.selectedTabbarSubviewController.view removeFromSuperview];
                                 self.selectedTabbarSubviewController = newCtr;
                                 selectedTabbarSubviewController.view.userInteractionEnabled = YES;
                                 
                                 //NSLog(@"%d %@ %@",[newCtr retainCount], newCtr, viewControllers);
                                 
                                 selectedPage = value;
                                 userFlags.disableScroll = NO;
                                 
#if DEBUG_TABBARCONTROLLER
                                 DLog(@"---------%@", viewControllers);
                                 for (id key in [viewControllers allKeys]) {
                                     id obj = [viewControllers objectForKey:key];
                                     DLog(@"key:%@, %@-%d", key, obj, [obj retainCount]);
                                 }
#endif
                                 
                                 TabbarItem *current = [self itemAtIndex:selectedPage];
                                 current.activated = YES;
                                 
                             }];
        }
    } else if (value == selectedPage  && !userFlags.disableScroll ) {
        if (!selectedTabbarSubviewController) {
            
            TabbarSubviewController *newCtr = [self viewControllerAtIndex:value];
            self.selectedTabbarSubviewController = newCtr;
            newCtr.view.frame = contentView.bounds;
            [contentView insertSubview:newCtr.view belowSubview:tabbar];

            TabbarItem *current = [self itemAtIndex:selectedPage];
            current.activated = NO;
            selectedPage = value;
            current = [self itemAtIndex:selectedPage];
            current.activated = YES;
        }
    }
}

- (void)setSelectedPage:(int)value tabBar:(BOOL)exist{
#if DEBUG_TABBARCONTROLLER
    NSLog(@"new page :%d", value);
#endif
    
    if ( value != selectedPage  && !userFlags.disableScroll ) {
        BOOL right = (selectedPage > value);
        TabbarSubviewController *newCtr = [self viewControllerAtIndex:value];
        if (newCtr) {
            CGRect newCtrFrame = contentView.frame;
            newCtrFrame.origin = CGPointZero;
            CGRect newCtrDstFrame = newCtrFrame, currentCtrDstFrame = newCtrFrame;
            
            if (right) {
                newCtrFrame.origin.x -= newCtrFrame.size.width;
                newCtr.view.frame = newCtrFrame;
                currentCtrDstFrame.origin.x += newCtrFrame.size.width;
             
            } else {
                newCtrFrame.origin.x += newCtrFrame.size.width;
                newCtr.view.frame = newCtrFrame;
                currentCtrDstFrame.origin.x -= newCtrFrame.size.width;
                
            }
            
            [contentView insertSubview:newCtr.view belowSubview:tabbar];
            
            
#if DEBUG_TABBARCONTROLLER
            DLog(@"old:%@ new:%@", selectedTabbarSubviewController, newCtr);
#endif

            
            [UIView
             animateWithDuration:.6
             animations:^{
                 userFlags.disableScroll = YES;
                 //for incoming controller
//                 TabbarItem *current = [self itemAtIndex:selectedPage];
//                 current.activated = NO;
                 
                 self.selectedTabbarSubviewController.view.frame = currentCtrDstFrame;
                 newCtr.view.frame = newCtrDstFrame;
             }
             completion:^(BOOL finished) {
                 
                 [self.selectedTabbarSubviewController.view removeFromSuperview];
                 self.selectedTabbarSubviewController = newCtr;
                 selectedTabbarSubviewController.view.userInteractionEnabled = YES;
                 
                 //NSLog(@"%d %@ %@",[newCtr retainCount], newCtr, viewControllers);
                 
                 selectedPage = value;
                 userFlags.disableScroll = NO;
                 
#if DEBUG_TABBARCONTROLLER
                 DLog(@"---------%@", viewControllers);
                 for (id key in [viewControllers allKeys]) {
                     id obj = [viewControllers objectForKey:key];
                     DLog(@"key:%@, %@-%d", key, obj, [obj retainCount]);
                 }
#endif
                 if (exist) {
                     TabbarItem *current = [self itemAtIndex:selectedPage];
                     current.activated = YES;
                 }
             
             }];
        }
    } else if (value == selectedPage  && !userFlags.disableScroll ) {
        if (!selectedTabbarSubviewController) {
            
            TabbarSubviewController *newCtr = [self viewControllerAtIndex:value];
            self.selectedTabbarSubviewController = newCtr;
            newCtr.view.frame = contentView.bounds;
            [contentView insertSubview:newCtr.view belowSubview:tabbar];
            if (exist) {
                TabbarItem *current = [self itemAtIndex:selectedPage];
                current.activated = NO;
                selectedPage = value;
                current = [self itemAtIndex:selectedPage];
                current.activated = YES;
            }
       
        }
    }
}


#pragma mark utility
- (void)setViewController:(NSString *)ctrName params:(NSDictionary *)param atIndex:(int)index {
    if (ctrName)
        [viewControllerClasses setObject:ctrName forKey:[NSNumber numberWithInt:index]];
    if (param)
        [viewControllerParams setObject:param forKey:[NSNumber numberWithInt:index]];
}

- (void)addItem:(TabbarItem *)item {
    item.delegate = self;
    [tabbar addSubview:item];
}

- (TabbarItem *)itemAtIndex:(int)idx {
    NSArray *views = [tabbar subviews];
    for (UIView *view in views) {
        if ([view isKindOfClass:[TabbarItem class]]) {
            TabbarItem *item = (TabbarItem *)view;
            if (item.index == idx) {
                return item;
            }
        }
    }
    return nil;
}

- (TabbarSubviewController *)viewControllerAtIndex:(int)index {
    TabbarSubviewController *ctr = [viewControllers objectForKey:[NSNumber numberWithInt:index]];
    
    if (!ctr) {
        NSString *className = [viewControllerClasses objectForKey:[NSNumber numberWithInt:index]];
        if (className) {
            ctr = (TabbarSubviewController *)[[NSClassFromString(className) alloc] init];
            NSDictionary *params = [viewControllerParams objectForKey:[NSNumber numberWithInt:index]];
            NSArray *allKeys = [params allKeys];
            for (NSString *key in allKeys) {
                [ctr setValue:[params objectForKey:key] forKey:key];
            }
            ctr.subviewDelegate = self;
            ctr.parentController = self;
            ctr.view.frame = contentView.frame;
            
            [viewControllers setObject:ctr forKey:[NSNumber numberWithInt:index]];
            [ctr release];
        }
    }
    
    return ctr;
}

- (void)swipeToLeft {
    if (!userFlags.disableScroll) {
        selectedTabbarSubviewController.view.userInteractionEnabled = NO;
        self.selectedPage = selectedPage + 1;   
    }
}

- (void)swipeToRight {
    if (!userFlags.disableScroll) {
        selectedTabbarSubviewController.view.userInteractionEnabled = NO;
        self.selectedPage = selectedPage - 1;
    }
}

- (BOOL)subTabbarShouldScroll {
    return [viewControllerClasses count] > 1;
}

- (float)tabbarHeight {
    return 44;
}

- (void)tabbarItemTouchedAtIndex:(int)index {

}

- (BOOL)tabbarItemShouldSelectAtIndex:(int)index {
    return YES;
}

- (void)setTabbarHidden:(BOOL)hide {
    tabbar.hidden = hide;
}


#pragma mark tabbaritem delegate
- (void)tabbarItem:(TabbarItem *)item touchedAtIndex:(int)idx {
    if (!userFlags.disableScroll) {
        if ([self tabbarItemShouldSelectAtIndex:idx]) {
            [self itemAtIndex:selectedPage].activated = NO;
            item.activated = YES;
            
            self.selectedPage = idx;
        }
        
        DLog(@"select item at index: %d", idx);
        [self tabbarItemTouchedAtIndex:idx];
    }
}


#pragma TabbarSubviewController delegate
- (void)tabbarSubViewDidScroll:(float)distance {
    if (!userFlags.disableScroll) {        
        CGRect currentFrame = selectedTabbarSubviewController.view.frame;
        currentFrame.origin.x = distance;
        selectedTabbarSubviewController.view.frame = currentFrame;
    }
}

- (void)tabbarSubViewDidEndScrolling {
    if (!userFlags.disableScroll) {
        CGRect currentFrame = selectedTabbarSubviewController.view.frame;
        float changePoint = currentFrame.size.width*kTabbarChangePagePoint;
        if (currentFrame.origin.x < -changePoint) {
            //NSLog(@"Tabbar scrolled");
            [self swipeToLeft];
        } else if (currentFrame.origin.x > changePoint) {
            //NSLog(@"Tabbar scrolled");
            [self swipeToRight];
        } else {
            double animationTime = .5*fabs(currentFrame.origin.x)/changePoint;
            currentFrame.origin.x = 0;
            [UIView animateWithDuration:animationTime
                             animations:^{
                                 selectedTabbarSubviewController.view.frame = currentFrame;
                             }];
            //NSLog(@"Tabbar reseted");
        }
    }
}


#pragma mark view life cycle
- (void)viewWillAppear:(BOOL)animated {
    if (!userFlags.initAppear) {
        [selectedTabbarSubviewController viewWillAppear:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated {
//    if (!userFlags.initAppear) {
        [selectedTabbarSubviewController viewDidAppear:animated];
//    } else {
//        userFlags.initAppear = NO;
//    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [selectedTabbarSubviewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [selectedTabbarSubviewController viewDidDisappear:animated];
}


@end
