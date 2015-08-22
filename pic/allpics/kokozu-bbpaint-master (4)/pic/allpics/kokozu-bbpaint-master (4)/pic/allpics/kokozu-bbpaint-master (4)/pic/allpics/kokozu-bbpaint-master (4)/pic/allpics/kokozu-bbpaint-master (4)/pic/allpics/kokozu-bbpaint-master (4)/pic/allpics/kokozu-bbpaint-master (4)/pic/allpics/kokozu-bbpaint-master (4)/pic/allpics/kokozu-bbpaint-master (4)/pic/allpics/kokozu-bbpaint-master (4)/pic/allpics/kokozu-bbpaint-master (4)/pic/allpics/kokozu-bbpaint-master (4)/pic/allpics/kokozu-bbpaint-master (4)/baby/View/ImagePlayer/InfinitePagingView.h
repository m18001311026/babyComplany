//
//  InfinitePagingView.h
//  simpleread
//
//  Created by zhang da on 11-4-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//


@class InfinitePagingView;


@protocol InfinitePagingViewDelegate <NSObject>

@required

- (void)configPage:(UIView *)page forIndex:(NSInteger)index;
- (NSInteger)numberOfPages;
- (float)widthForPage;

@optional
- (void)selectedPageChangedTo:(NSInteger)newPage;

@end



@interface InfinitePagingView : UIView < UIScrollViewDelegate >{
    
    UIScrollView *holderScrollView;
        
    NSMutableSet *visiblePages;
    NSMutableSet *recycledPages;

}


@property (nonatomic, assign) id <InfinitePagingViewDelegate> delegate;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL dragging;
@property (nonatomic, readonly) BOOL decelerating;

- (void)reloadData;
- (void)scrollToRowAtIndex:(NSInteger)index animated:(BOOL)animated;

@end
