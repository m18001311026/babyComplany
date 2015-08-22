//
//  HorizonTableView.h
//  simpleread
//
//  Created by zhang da on 11-4-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshView.h"

@class HorizonTableView;

@protocol HorizonTableViewDelegate <NSObject>

@optional
- (int)rowWidthForHorizonTableView:(HorizonTableView *)tableView;
- (void)horizonTableView:(HorizonTableView *)tableView didSelectRowAtIndex:(NSInteger)index;
- (void)horizonTableView:(HorizonTableView *)tableView loadHeavyDataForCell:(UIView *)cell atIndex:(NSInteger)index;

- (void)horizonTableViewDidTriggerRefresh:(HorizonTableView *)pullTableView;
- (void)horizonTableViewDidTriggerLoadMore:(HorizonTableView *)pullTableView;
@end 

@protocol HorizonTableViewDatasource <NSObject>

@required
- (NSInteger)numberOfRowsInHorizonTableView:(HorizonTableView *)tableView;
- (UIView *)horizonTableView:(HorizonTableView *)tableView cellForRowAtIndex:(NSInteger)index;

@end 

@interface HorizonTableView: UIView  < UIScrollViewDelegate >{
    UIScrollView *holderScrollView;
    NSRange visibleRange;
    
    PullToRefreshView *refreshView, *loadMoreView;
    
    NSMutableSet *visibleCells;
    NSMutableSet *recycledCells;
}

@property (nonatomic, assign) id <HorizonTableViewDelegate> delegate;
@property (nonatomic, assign) id <HorizonTableViewDatasource> dataSource;
@property (nonatomic, assign) bool hasMore;
@property (nonatomic, assign, readonly) NSInteger currentPage;

- (id)dequeueReusableCell;
- (id)cellAtIndex:(NSInteger)index;
- (void)scrollToRowAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)stopLoading;
- (void)reloadData;
- (void)setReloadIndicatoreColor:(UIColor *)color;

@end
