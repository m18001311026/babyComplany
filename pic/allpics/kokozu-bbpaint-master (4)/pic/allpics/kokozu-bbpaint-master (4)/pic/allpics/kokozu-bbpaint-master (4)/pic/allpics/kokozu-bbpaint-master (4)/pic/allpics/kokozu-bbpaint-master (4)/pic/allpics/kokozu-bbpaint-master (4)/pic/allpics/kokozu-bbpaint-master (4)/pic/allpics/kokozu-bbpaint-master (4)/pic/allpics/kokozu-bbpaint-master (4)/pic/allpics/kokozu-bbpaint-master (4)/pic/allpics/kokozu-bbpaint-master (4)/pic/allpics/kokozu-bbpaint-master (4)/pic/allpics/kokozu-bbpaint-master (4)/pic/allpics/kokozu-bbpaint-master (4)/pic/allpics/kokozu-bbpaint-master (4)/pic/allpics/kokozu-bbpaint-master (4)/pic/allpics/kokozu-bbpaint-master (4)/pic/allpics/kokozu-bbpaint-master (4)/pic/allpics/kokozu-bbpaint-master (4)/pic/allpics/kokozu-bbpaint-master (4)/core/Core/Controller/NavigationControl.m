//
//  NavigationControl.m
//  KoMovie
//
//  Created by alfaromeo on 12-6-18.
//  Copyright (c) 2012年 kokozu. All rights reserved.
//

#import "NavigationControl.h"
#import "TabbarController.h"


#define kOriginFrame CGRectMake(0, 20, 320, screentContentHeight)
#define kBounceAnimationDuration .2
#define kFlipAnimationDuration .2
#define kSwipeAnimationDuration .3


@implementation NavigationControl


@synthesize holder;


- (void)dealloc {
    self.holder = nil;
    
    [viewControllerStack removeAllObjects];
    [viewControllerStack release];
    
    [super dealloc];
}

- (id)initWithHolder:(UIWindow *)viewHolder {
    self = [super init];
    if (self) {
        self.holder = viewHolder;
        viewControllerStack = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSInteger)numberOfControllers {
    return [viewControllerStack count];
}

- (bool)onTop:(id)ctr {
    return viewControllerStack.count > 0 && viewControllerStack.lastObject == ctr;
}

- (void)setViewControllerHidden:(BOOL)hide atIndex:(int)idx {
    id viewCtr = nil;
    if ([viewControllerStack count] >= idx) {
        viewCtr = [viewControllerStack objectAtIndex:idx];
    }

    UIView *theView = nil;
    if ([viewCtr isKindOfClass:[TabbarController class]]) {
        TabbarController *controller = (TabbarController *)viewCtr;
        theView = controller.contentView;
    } else if ([viewCtr isKindOfClass:[UIViewController class]]) {
        UIViewController *controller = (UIViewController *)viewCtr;
        theView = controller.view;
    }
    theView.hidden = hide;
}

- (UIView *)viewForController:(id)ctr {
    if ([ctr isKindOfClass:[TabbarController class]]) {
        TabbarController *controller = (TabbarController *)ctr;
        return controller.contentView;
    } else if ([ctr isKindOfClass:[UIViewController class]]) {
        UIViewController *controller = (UIViewController *)ctr;
        return controller.view;
    } else {
        return nil;
    }
}

- (void)didShowViewController:(id)newCtr andHideController:(id)currentCtr {
    if (currentCtr
        &&  ([currentCtr isKindOfClass:[UIViewController class]]
             || [currentCtr isKindOfClass:[TabbarController class]])
        && [currentCtr respondsToSelector:@selector(viewDidDisappear:)]) {
        [currentCtr viewDidDisappear:NO];
    }
    if (newCtr
        && ([newCtr isKindOfClass:[UIViewController class]]
            || [newCtr isKindOfClass:[TabbarController class]])
        && [newCtr respondsToSelector:@selector(viewDidAppear:)]) {
        [newCtr viewDidAppear:NO];
    }
}

- (void)willShowViewController:(id)newCtr andHideController:(id)currentCtr {
    if (currentCtr
        &&  ([currentCtr isKindOfClass:[UIViewController class]]
             || [currentCtr isKindOfClass:[TabbarController class]])
        && [currentCtr respondsToSelector:@selector(viewWillDisappear:)]) {
        [currentCtr viewWillDisappear:NO];
    }
    if (newCtr
        && ([newCtr isKindOfClass:[UIViewController class]]
            || [newCtr isKindOfClass:[TabbarController class]])
        && [newCtr respondsToSelector:@selector(viewWillAppear:)]) {
        [newCtr viewWillAppear:NO];
    }
}


#pragma mark push
- (void)pushViewController:(id)ctr
                 animation:(ViewSwitchAnimation)animation
                  finished:(void(^)())fBlock {
    if (!ctr || stackLock)
        return;
    
    stackLock = YES;
    
    id topViewController = [viewControllerStack lastObject];
    
    if (ctr == topViewController) {
        stackLock = NO;
        return;
    }
    
    UIView *newTopView = [self viewForController:ctr];
    UIView *currentTopView = [self viewForController:topViewController];
    
    if ([ctr isKindOfClass:[TabbarController class]]) {
        
        newTopView.frame = CGRectMake(0, 20, 320, screentContentHeight);
        ((TabbarController *)ctr).appearAnimation = animation;
        
    }  else if ([ctr isKindOfClass:[BBViewController class]]) {
        
        ((BBViewController *)ctr).appearAnimation = animation;
        
    }
    
    [self willShowViewController:nil andHideController:topViewController];
    
    [holder addSubview:newTopView];
    [viewControllerStack addObject:ctr];
    
    if (animation == ViewSwitchAnimationBounce) {
        
        newTopView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
        
        [UIView animateWithDuration:kBounceAnimationDuration
                         animations:^{
                             newTopView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                             newTopView.frame = kOriginFrame;
                         }
                         completion:^(BOOL finished) {
                             newTopView.transform = CGAffineTransformIdentity;
                             currentTopView.frame = kOriginFrame;

                             //set view controller under top hidden
                             //-----                             currentTopView.hidden = YES;
                             
                             stackLock = NO;
                             
                             [self didShowViewController:nil andHideController:topViewController];
                             
                             fBlock();
                         }];
        
    } else if (animation == ViewSwitchAnimationFade) {
        
        newTopView.alpha = 0.1;
        
        [UIView animateWithDuration:kBounceAnimationDuration
                         animations:^{
                             newTopView.alpha = 1;
                         }
                         completion:^(BOOL finished) {
                             currentTopView.frame = kOriginFrame;
                             
                             stackLock = NO;
                             
                             [self didShowViewController:nil andHideController:topViewController];
                             
                             fBlock();
                         }];
        
    } else if (animation == ViewSwitchAnimationFlipL
               || animation == ViewSwitchAnimationFlipR) {
        
        
        [UIView transitionFromView:currentTopView
                            toView:newTopView
                          duration:kFlipAnimationDuration
                           options:(animation == ViewSwitchAnimationFlipL?
                                    UIViewAnimationOptionTransitionFlipFromLeft:
                                    UIViewAnimationOptionTransitionFlipFromRight)
                        completion:^(BOOL finished) {

                            currentTopView.frame = kOriginFrame;
                            
                            stackLock = NO;
                            
                            [self didShowViewController:nil andHideController:topViewController];
                            
                            fBlock();

                        }];
        
    } else if (animation == ViewSwitchAnimationSwipeD2U
               || animation == ViewSwitchAnimationSwipeU2D
               || animation == ViewSwitchAnimationSwipeL2R
               || animation == ViewSwitchAnimationSwipeR2L) {
        
        CGRect originFrame = kOriginFrame;
        CGRect newFrame = kOriginFrame;
        if (animation == ViewSwitchAnimationSwipeD2U) {
            originFrame.origin.y = screentHeight;
            newFrame.origin.y = -screentHeight;
        } else if (animation == ViewSwitchAnimationSwipeU2D) {
            originFrame.origin.y = -screentHeight;
            newFrame.origin.y = screentHeight;
        } else if (animation == ViewSwitchAnimationSwipeL2R) {
            originFrame.origin.x = -320;
            newFrame.origin.x = 320;
        } else if (animation == ViewSwitchAnimationSwipeR2L) {
            originFrame.origin.x = 320;
            newFrame.origin.x = -320;
        }
        newTopView.frame = originFrame;
        
        [UIView animateWithDuration:kSwipeAnimationDuration
                         animations:^{
                             newTopView.frame = kOriginFrame;
                             currentTopView.frame = newFrame;
                         }
                         completion:^(BOOL finished) {
                             //-----                             currentTopView.hidden = YES;
                             currentTopView.frame = kOriginFrame;
                             
                             stackLock = NO;
                             
                             [self didShowViewController:nil andHideController:topViewController];
                             
                             fBlock();
                             
                         }];
        
    } else if (animation == ViewSwitchAnimationWP7Flip) {
        
        [newTopView removeFromSuperview];
        
        [UIView animateWithDuration:.2
                         animations:^{
                             CATransform3D t = CATransform3DIdentity;
                             t = CATransform3DTranslate(t, -140, 0, 0.0);
                             t.m34 = 1.0 / -4000;
                             t = CATransform3DRotate(t, -80.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
                             t = CATransform3DTranslate(t, 180, 0, 0.0);
                             
                             currentTopView.layer.transform = t;
                         }
                         completion:^(BOOL finished) {
                             //set view controller under top hidden
                             //-----                             currentTopView.hidden = YES;
                             
                             CATransform3D t = CATransform3DIdentity;
                             t = CATransform3DTranslate(t, -140, 0, 0.0);
                             t.m34 = 1.0 / -4000;
                             t = CATransform3DRotate(t, 30.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
                             t = CATransform3DTranslate(t, 180, 0, 0.0);
                             
                             newTopView.layer.transform = t;
                             [holder addSubview:newTopView];
                             
                             [UIView animateWithDuration:.1
                                              animations:^{
                                                  
                                                  newTopView.layer.transform
                                                  = CATransform3DRotate(CATransform3DIdentity, 0, 0, 0, 0);
                                              }
                                              completion:^(BOOL finished) {
                                                  
                                                  currentTopView.layer.transform
                                                  = CATransform3DRotate(CATransform3DIdentity, 0, 0, 0, 0);
                                                  
                                                  stackLock = NO;
                                                  
                                                  [self didShowViewController:nil andHideController:topViewController];
                                                  
                                                  fBlock();
                                                  
                                              }];
                             
                         }];
    } else {
        //set view controller under top hidden
        //-----        currentTopView.hidden = YES;
        newTopView.frame = kOriginFrame;
        stackLock = NO;
        [self didShowViewController:nil andHideController:topViewController];
        
        fBlock();
    }
}

- (void)pushViewController:(id)ctr animation:(ViewSwitchAnimation)animation {
    [self pushViewController:ctr animation:animation finished:^{}];
}

- (void)switchToViewController:(id)ctr animation:(ViewSwitchAnimation)animation {
    [self pushViewController:ctr animation:animation finished:^{
        if ([viewControllerStack count] > 1) {
            id ctrToRemove = [viewControllerStack objectAtIndex:[viewControllerStack count] - 2];
            
            [ctr setValue:[ctrToRemove valueForKeyPath:@"appearAnimation"] forKeyPath:@"appearAnimation"];
            
            if (ctrToRemove) {
                UIView *viewToRemove = [self viewForController:ctrToRemove];
                [viewToRemove removeFromSuperview];
                [viewControllerStack removeObject:ctrToRemove];
            }
        }
    }];
}


#pragma mark pop
- (void)popViewControllerWithAnimation:(ViewSwitchAnimation)animation {
    [self popToIndex:viewControllerStack.count - 2 animation:animation];
}

- (void)popViewControllerAnimated:(BOOL)animated {

    id topViewController = [viewControllerStack lastObject];
    if (!topViewController)
        return;
    
    ViewSwitchAnimation animation = ViewSwitchAnimationNone;
    
    if (animated) {
        if ([topViewController isKindOfClass:[TabbarController class]]) {
            
            animation = ((TabbarController *)topViewController).appearAnimation;
            
        } else if ([topViewController isKindOfClass:[BBViewController class]]) {
            
            animation = ((BBViewController *)topViewController).appearAnimation;
            
        } else if ([topViewController isKindOfClass:[UINavigationController class]]) {
            
            animation = ViewSwitchAnimationBounce;
            
        }
        
        switch (animation) {
            case ViewSwitchAnimationSwipeL2R: {
                animation = ViewSwitchAnimationSwipeR2L;
                break;
            }
            case ViewSwitchAnimationSwipeR2L: {
                animation = ViewSwitchAnimationSwipeL2R;
                break;
            }
            case ViewSwitchAnimationSwipeD2U: {
                animation = ViewSwitchAnimationSwipeU2D;
                break;
            }
            case ViewSwitchAnimationSwipeU2D: {
                animation = ViewSwitchAnimationSwipeD2U;
                break;
            }
            default:
                break;
        }
    }
    
    [self popViewControllerWithAnimation:animation];
}

- (void)popToIndex:(NSInteger)index animation:(ViewSwitchAnimation)animation {
    if (index < 0 || index >= viewControllerStack.count - 1) {
        return;
    }
    
    if (stackLock)
        return;
    
    id topViewController = [viewControllerStack lastObject];
    id activeViewController = [viewControllerStack objectAtIndex:index];
    
    if (!topViewController) {
        stackLock = NO;
        return;
    }
    
    NSMutableArray *toRemove = [[NSMutableArray alloc] init];
    for (NSInteger i = index + 1; i < viewControllerStack.count - 1; i++) {
        id viewController = [viewControllerStack objectAtIndex:i];
        UIView *ctrView = nil;
        if ([viewController isKindOfClass:[UIViewController class]]) {
            UIViewController *controller = (UIViewController *)viewController;
            ctrView = controller.view;
        }
        [toRemove addObject:viewController];
        [ctrView removeFromSuperview];
    }
    [viewControllerStack removeObjectsInArray:toRemove];
    [toRemove removeAllObjects];
    [toRemove release];
    
    stackLock = YES;
    //    [self willShowViewController:activeViewController andHideController:topViewController];
    [self willShowViewController:activeViewController andHideController:nil];
    
    UIView *newTopView = [self viewForController:activeViewController];
    UIView *currentTopView = [self viewForController:topViewController];
    
    if ([topViewController isKindOfClass:[TabbarController class]]) {
        currentTopView.frame = kOriginFrame;
    }
    
    //set view controller under top unhidden
    //-----    newTopView.hidden = NO;
    
    if (animation == ViewSwitchAnimationBounce) {
        
        [UIView animateWithDuration:kBounceAnimationDuration
                         animations:^{
                             currentTopView.transform = CGAffineTransformScale(CGAffineTransformIdentity, .2, .2);
                             currentTopView.alpha = .1;
                         }
                         completion:^(BOOL finished) {
                             [currentTopView removeFromSuperview];
                             currentTopView.alpha = 1;
                             [viewControllerStack removeLastObject];
                             stackLock = NO;
                             
                             //                             [self didShowViewController:activeViewController andHideController:topViewController];
                             [self didShowViewController:activeViewController andHideController:nil];
                             
                         }];
        
    } else if (animation == ViewSwitchAnimationFade) {
        
        [UIView animateWithDuration:kBounceAnimationDuration
                         animations:^{
                             //currentTopView.transform = CGAffineTransformScale(CGAffineTransformIdentity, .2, .2);
                             currentTopView.alpha = .1;
                         }
                         completion:^(BOOL finished) {
                             [currentTopView removeFromSuperview];
                             currentTopView.alpha = 1;
                             [viewControllerStack removeLastObject];
                             stackLock = NO;
                             
                             //                             [self didShowViewController:activeViewController andHideController:topViewController];
                             [self didShowViewController:activeViewController andHideController:nil];
                             
                         }];
        
    } else if (animation == ViewSwitchAnimationSwipeD2U
               || animation == ViewSwitchAnimationSwipeU2D
               || animation == ViewSwitchAnimationSwipeL2R
               || animation == ViewSwitchAnimationSwipeR2L) {
        
        CGRect originFrame = kOriginFrame;
        CGRect newFrame = kOriginFrame;
        if (animation == ViewSwitchAnimationSwipeD2U) {
            originFrame.origin.y = screentHeight;
            newFrame.origin.y = -screentHeight;
        } else if (animation == ViewSwitchAnimationSwipeU2D) {
            originFrame.origin.y = -screentHeight;
            newFrame.origin.y = screentHeight;
        } else if (animation == ViewSwitchAnimationSwipeL2R) {
            originFrame.origin.x = -320;
            newFrame.origin.x = 320;
        } else if (animation == ViewSwitchAnimationSwipeR2L) {
            originFrame.origin.y = 320;
            newFrame.origin.y = -320;
        }
        newTopView.frame = originFrame;
        
        [UIView animateWithDuration:kSwipeAnimationDuration
                         animations:^{
                             newTopView.frame = kOriginFrame;
                             currentTopView.frame = newFrame;
                         }
                         completion:^(BOOL finished) {
                             [currentTopView removeFromSuperview];
                             
                             [viewControllerStack removeLastObject];
                             stackLock = NO;
                             //                             [self didShowViewController:activeViewController andHideController:topViewController];
                             [self didShowViewController:activeViewController andHideController:nil];
                             
                         }];
        
    } else if (animation == ViewSwitchAnimationFlipL
               || animation == ViewSwitchAnimationFlipR) {
        
        
        [UIView transitionFromView:currentTopView
                            toView:newTopView
                          duration:kFlipAnimationDuration
                           options:(animation == ViewSwitchAnimationFlipL?
                                    UIViewAnimationOptionTransitionFlipFromLeft:
                                    UIViewAnimationOptionTransitionFlipFromRight)
                        completion:^(BOOL finished) {
                            [currentTopView removeFromSuperview];
                            
                            [viewControllerStack removeLastObject];
                            stackLock = NO;
                            //                             [self didShowViewController:activeViewController andHideController:topViewController];
                            [self didShowViewController:activeViewController andHideController:nil];
                            
                        }];
        
    } else if (animation == ViewSwitchAnimationWP7Flip) {
        //-----        newTopView.hidden = YES;
        
        [UIView animateWithDuration:.2
                         animations:^{
                             CATransform3D t = CATransform3DIdentity;
                             t = CATransform3DTranslate(t, -140, 0, 0.0);
                             t.m34 = 1.0 / -4000;
                             t = CATransform3DRotate(t, 80.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
                             t = CATransform3DTranslate(t, 180, 0, 0.0);
                             
                             currentTopView.layer.transform = t;
                         }
                         completion:^(BOOL finished) {
                             [currentTopView removeFromSuperview];
                             
                             CATransform3D t = CATransform3DIdentity;
                             t = CATransform3DTranslate(t, -140, 0, 0.0);
                             t.m34 = 1.0 / -4000;
                             t = CATransform3DRotate(t, -40.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
                             t = CATransform3DTranslate(t, 180, 0, 0.0);
                             
                             newTopView.layer.transform = t;
                             
                             [UIView animateWithDuration:.2
                                              animations:^{
                                                  
                                                  newTopView.layer.transform
                                                  = CATransform3DRotate(CATransform3DIdentity, 0, 0, 0, 0);
                                              }
                                              completion:^(BOOL finished) {
                                                  [viewControllerStack removeLastObject];
                                                  stackLock = NO;
                                                  
                                                  //                             [self didShowViewController:activeViewController andHideController:topViewController];
                                                  [self didShowViewController:activeViewController andHideController:nil];
                                                  
                                              }];
                             
                         }];
    } else {
        [currentTopView removeFromSuperview];
        [viewControllerStack removeLastObject];
        stackLock = NO;
        
        //                             [self didShowViewController:activeViewController andHideController:topViewController];
        [self didShowViewController:activeViewController andHideController:nil];
        
    }
    
}

- (void)popToViewController:(id)ctr animation:(ViewSwitchAnimation)animation {
    if (stackLock)
        return;
    NSInteger index = [viewControllerStack indexOfObject:ctr];
    if (index != NSNotFound) {
        [self popToIndex:index animation:animation];
    }
}

- (void)popToRootViewControllerWithAnimation:(ViewSwitchAnimation)animation {
    [self popToIndex:0 animation:animation];
}


@end
