//
//  TabbarSubviewController.h
//  TestWP7View
//
//  Created by alfaromeo on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabbarControllerConfig.h"
#import "BBViewController.h"

@class TabbarController;

@protocol TabbarSubviewControllerDelegate <NSObject>

@required
- (void)tabbarSubViewDidScroll:(float)distance;
- (void)tabbarSubViewDidEndScrolling;
@end

@interface TabbarSubviewController : BBViewController <UIGestureRecognizerDelegate> {
    TabbarController *parentController;
    
    float panOriginX;
    CGPoint panVelocity;
    SwipeDirection swipeDirection;
}

@property (nonatomic, assign) id<TabbarSubviewControllerDelegate> subviewDelegate;
@property (nonatomic, assign) TabbarController *parentController;

- (float)contentOriginY;
- (BOOL)swipeEnabled;

@end
