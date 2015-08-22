//
//  SplashViewController.m
//  baby
//
//  Created by zhang da on 14-7-10.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "SplashViewController.h"

@interface SplashViewController () {
    UIScrollView *scrollView;
    UIPageControl *paging;
}

@end



@implementation SplashViewController

- (void)dealloc {
    
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0f blue:255/255.0f alpha:1];
        
        scrollView = [[UIScrollView alloc] init];
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.contentSize = CGSizeMake(320*3, screentContentHeight);
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;
        scrollView.showsHorizontalScrollIndicator = NO;
        [self.view addSubview:scrollView];
        [scrollView release];
        
        paging = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 200, 320, 20)];
        paging.hidesForSinglePage = YES;
        paging.userInteractionEnabled = NO;
        paging.numberOfPages = 3;
        [self.view addSubview:paging];
        [paging release];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            scrollView.frame = CGRectMake(0, 0, 320, screentHeight);
            paging.frame = CGRectMake(0, screentHeight - 50, 320, 20);
        } else {
            scrollView.frame = CGRectMake(0, 0, 320, screentContentHeight);
            paging.frame = CGRectMake(0, screentContentHeight - 50, 320, 20);
        }

        UIImageView *view1 = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                           0,
                                                                           320,
                                                                           screentContentHeight)];
        view1.contentMode = UIViewContentModeScaleAspectFit;
       // view1.backgroundColor = [UIColor clearColor];
        view1.image = [UIImage imageNamed:@"sw1.png"];
        [scrollView addSubview:view1];
        [view1 release];
        
        UIImageView *view2 = [[UIImageView alloc] initWithFrame:CGRectMake(320,
                                                                           0,
                                                                           320,
                                                                           screentContentHeight)];
        view2.contentMode = UIViewContentModeScaleAspectFit;
        view2.backgroundColor = [UIColor clearColor];
        view2.image = [UIImage imageNamed:@"sw2.png"];
        [scrollView addSubview:view2];
        [view2 release];
        
        UIImageView *view3 = [[UIImageView alloc] initWithFrame:CGRectMake(640,
                                                                           0,
                                                                           320,
                                                                           screentContentHeight)];
        view3.contentMode = UIViewContentModeScaleAspectFit;
        
        view3.backgroundColor = [UIColor clearColor];
        view3.image = [UIImage imageNamed:@"sw3.png"];
        [scrollView addSubview:view3];
        [view3 release];
        
//        UIImageView *view4 = [[UIImageView alloc] initWithFrame:CGRectMake(960,
//                                                                           0,
//                                                                           320,
//                                                                           screentContentHeight)];
//        view4.contentMode = UIViewContentModeScaleAspectFit;
//        view4.backgroundColor = [UIColor clearColor];
//        view4.image = [UIImage imageNamed:@"s4.jpg"];
//        view4.userInteractionEnabled = YES;
//        [scrollView addSubview:view4];
//        [view4 release];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)sView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.x > 320*2+40) {
        sView.delegate = nil;
        [ctr popViewControllerAnimated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sView {
    int newpage = (int)((scrollView.contentOffset.x / scrollView.bounds.size.width));
    if (paging.currentPage != newpage) {
        paging.currentPage = newpage;
    }
}


@end
