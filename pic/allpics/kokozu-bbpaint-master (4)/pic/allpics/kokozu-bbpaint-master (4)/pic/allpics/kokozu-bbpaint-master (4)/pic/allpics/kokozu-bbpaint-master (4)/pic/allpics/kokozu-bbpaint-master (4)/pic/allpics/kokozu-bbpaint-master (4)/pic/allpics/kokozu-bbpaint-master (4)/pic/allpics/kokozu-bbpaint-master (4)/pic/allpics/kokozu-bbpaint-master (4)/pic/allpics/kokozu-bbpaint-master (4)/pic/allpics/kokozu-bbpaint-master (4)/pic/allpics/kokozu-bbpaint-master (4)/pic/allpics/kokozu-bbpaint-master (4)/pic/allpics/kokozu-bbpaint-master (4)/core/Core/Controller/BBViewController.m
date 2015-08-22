//
//  KKZViewController.m
//  KKZ
//
//  Created by alfaromeo on 12-3-9.
//  Copyright (c) 2012年 kokozu. All rights reserved.
//


#import "BBViewController.h"

@implementation BBViewController

@synthesize appearAnimation;

#pragma mark - View lifecycle
- (void)dealloc {
    [bbTopbar release];
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        bbTopbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 43.5)];
        bbTopbar.backgroundColor = [UIColor clearColor];
        bbTopbar.userInteractionEnabled = YES;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    userFlags.initAppear = YES;
    
    if ([self showTopbar]) {
        [self.view addSubview:bbTopbar];
    }
}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    userFlags.initAppear = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (bbTopbar && [bbTopbar superview]) {
        [self.view bringSubviewToFront:bbTopbar];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)showTopbar {
    return YES;
}

- (void)setTopbarHeight:(float)height{
    bbTopbar.frame = CGRectMake(0, 0, 320, height);
}

- (void)setViewTitle:(NSString *)viewTitle {
    if (bbTopbar) {
        if (!bbTitleLabel) {
            bbTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 13, 280, 20)];
            bbTitleLabel.backgroundColor = [UIColor clearColor];
            bbTitleLabel.font = [UIFont boldSystemFontOfSize:18];
            bbTitleLabel.textColor = [UIColor blackColor];
            bbTitleLabel.textAlignment = NSTextAlignmentCenter;
            [bbTopbar addSubview:bbTitleLabel];
            [bbTitleLabel release];
        }
        bbTitleLabel.text = viewTitle;
    }
}

- (void)setTopBarBackgroundColor:(UIColor *)color {
    bbTopbar.backgroundColor = color;
}

@end
