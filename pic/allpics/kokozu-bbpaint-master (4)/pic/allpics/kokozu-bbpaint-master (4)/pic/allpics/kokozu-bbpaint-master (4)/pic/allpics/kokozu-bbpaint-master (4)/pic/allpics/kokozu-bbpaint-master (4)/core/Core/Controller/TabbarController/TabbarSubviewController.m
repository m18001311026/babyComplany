//
//  TabbarSubviewController.m
//  TestWP7View
//
//  Created by alfaromeo on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TabbarSubviewController.h"
#import "TabbarController.h"

@implementation TabbarSubviewController

@synthesize subviewDelegate;
@synthesize parentController;

- (void)dealloc {  
    subviewDelegate = nil;
    parentController = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    pan.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:pan];
    [pan release];
}

- (TabbarController *)parentController {
    if ([parentController isKindOfClass:[TabbarController class]]) {
        return parentController;
    }
    return nil;
}



#pragma mark - GestureRecognizers
- (void)pan:(UIPanGestureRecognizer*)gesture {
    if (![self swipeEnabled]) {
        return;
    }
    if (![self.parentController subTabbarShouldScroll]) {
        return;
    }
    if (gesture.state == UIGestureRecognizerStateBegan) {
        panOriginX = self.view.frame.origin.x;        
        panVelocity = CGPointMake(0.0f, 0.0f);
        
        if([gesture velocityInView:self.view].x > 0) {
            swipeDirection = SwipeDirectionRight;
        } else {
            swipeDirection = SwipeDirectionLeft;
        }
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint velocity = [gesture velocityInView:self.view];
        if((velocity.x*panVelocity.x + velocity.y*panVelocity.y) < 0) {
            swipeDirection = (swipeDirection == SwipeDirectionRight)? SwipeDirectionLeft: SwipeDirectionRight;
        }
        panVelocity = velocity;        
        CGPoint translation = [gesture translationInView:self.view];
        float distance = panOriginX + translation.x;

        if (subviewDelegate) {
            [subviewDelegate tabbarSubViewDidScroll:distance];
        }
        
    } else if (gesture.state == UIGestureRecognizerStateEnded 
               || gesture.state == UIGestureRecognizerStateCancelled) {
        if (subviewDelegate) {
            [subviewDelegate tabbarSubViewDidEndScrolling];
        }
    }    
}

- (float)contentOriginY {
    return [self.parentController tabbarHeight];
}

- (BOOL)swipeEnabled {
    return YES;
}

@end
