//
//  HorizonTableView.m
//  simpleread
//
//  Created by zhang da on 11-4-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "HorizonTableView.h"

@interface HorizonTableView (Private)

- (void)tilePages;
- (NSInteger)indexFromFrame:(CGRect)frame;

- (NSInteger)currentPageIndex;
- (CGRect)frameForPageAtIndex:(NSInteger)index;

- (int)widthForRow;
- (NSInteger)numOfCells;

@end


@implementation HorizonTableView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        
        holderScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        holderScrollView.backgroundColor = [UIColor clearColor];
        holderScrollView.showsHorizontalScrollIndicator = NO;
        holderScrollView.alwaysBounceHorizontal = YES;
        holderScrollView.clipsToBounds = NO;
        holderScrollView.pagingEnabled = YES;
        holderScrollView.delegate = self;
        [self addSubview:holderScrollView];
        
        refreshView = [[PullToRefreshView alloc] initWithFrame:CGRectMake(-40,
                                                                          0.0f,
                                                                          40,
                                                                          holderScrollView.bounds.size.height)];
        refreshView.titleColor = [UIColor whiteColor];
        [holderScrollView addSubview:refreshView];
        
        loadMoreView = [[PullToRefreshView alloc] initWithFrame:CGRectMake(holderScrollView.bounds.size.width,
                                                                           0.0f,
                                                                           40,
                                                                           holderScrollView.bounds.size.height)];
        loadMoreView.titleColor = [UIColor whiteColor];
        [holderScrollView addSubview:loadMoreView];
        
        visibleCells = [[NSMutableSet alloc] init];
        recycledCells = [[NSMutableSet alloc] init];
        
        visibleRange = NSMakeRange(0, 0);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(tapDetected:)];
        //tap.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tap];
        [tap release];
        
        [self tilePages];
    }
    return self;
}

- (void)dealloc {
    [visibleCells release];
    [recycledCells release];
    
    [refreshView release];
    [loadMoreView release];
    [holderScrollView release];
    [super dealloc];
}

- (void)setHasMore:(bool)hasMore {
    if (hasMore) {
        if (![loadMoreView superview]) {
            [holderScrollView addSubview:loadMoreView];
        }
    } else {
        [loadMoreView removeFromSuperview];
        
        UIEdgeInsets origin = holderScrollView.contentInset;
        origin.right = 0;
        holderScrollView.contentInset = origin;
    }
}


#pragma mark utility
- (void)reloadData {
    NSInteger currentIndex = [self currentPageIndex];

    //force reset visible cells
    for (UIView *cell in visibleCells) {
        [recycledCells addObject:cell];
        [cell removeFromSuperview];
    }
    [visibleCells minusSet:recycledCells];
    visibleRange = NSMakeRange(0, -1);
    ////////////////////////
    
    [self tilePages];

    holderScrollView.contentSize = CGSizeMake( MAX([self widthForRow]*[self numOfCells], holderScrollView.frame.size.width),
                                              holderScrollView.frame.size.height);

    loadMoreView.frame = CGRectMake(holderScrollView.contentSize.width,
                                    0.0f,
                                    40,
                                    holderScrollView.bounds.size.height);
    
    NSInteger maxPages = [self numOfCells];
    if (maxPages < currentIndex) {
        [self scrollToRowAtIndex:maxPages animated:NO];
    }
}

- (int)widthForRow {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rowWidthForHorizonTableView:)]) {
        return [self.delegate rowWidthForHorizonTableView:self];
    }
    return 44;
}

- (NSInteger)numOfCells {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfRowsInHorizonTableView:)]) {
        return [self.dataSource numberOfRowsInHorizonTableView:self];
    }
    return 0;
}

- (void)doHeavyWorkForVisibleRows {
    if (self.delegate && [self.delegate respondsToSelector:@selector(horizonTableView:loadHeavyDataForCell:atIndex:)]) {
        for (UIView *cell in visibleCells) {
            NSInteger cellIndex = [self indexFromFrame:cell.frame];
            [self.delegate horizonTableView:self loadHeavyDataForCell:cell atIndex:cellIndex];
        }
    }
}

- (void)scrollToRowAtIndex:(NSInteger)index animated:(BOOL)animated {
    NSInteger maxPages = [self numOfCells];
    float maxOffset = holderScrollView.contentSize.width - holderScrollView.frame.size.width;
    
    if (index <= maxPages) {
        CGRect lastPageFrame = [self frameForPageAtIndex:index];
        if (lastPageFrame.origin.x < maxOffset) {
            [holderScrollView setContentOffset:CGPointMake(lastPageFrame.origin.x, 0) animated:animated];
        } else {
            [holderScrollView setContentOffset:CGPointMake(maxOffset, 0) animated:animated];
        }
    } else {
        CGRect lastPageFrame = [self frameForPageAtIndex:maxPages];
        if (lastPageFrame.origin.x < maxOffset) {
            [holderScrollView setContentOffset:CGPointMake(lastPageFrame.origin.x, 0) animated:animated];
        } else {
            [holderScrollView setContentOffset:CGPointMake(maxOffset, 0) animated:animated];
        }
    }
}

- (id)cellAtIndex:(NSInteger)index {
    for (UIView *cell in visibleCells) {
        NSInteger cellIndex = [self indexFromFrame:cell.frame];
        if (cellIndex == index) {
            return [[cell retain] autorelease];
        }
    }
    return nil;
}

- (void)tapDetected:(UITapGestureRecognizer *)gesture {
    for (UIView *view in visibleCells) {
        CGPoint point = [gesture locationInView:view];
        if ([view pointInside:point withEvent:nil]) {
            NSInteger cellIndex = [self indexFromFrame:view.frame];
            if (self.delegate && [self.delegate respondsToSelector:@selector(horizonTableView:didSelectRowAtIndex:)]) {
                [self.delegate horizonTableView:self didSelectRowAtIndex:cellIndex];
            }
            return;
        }
    }
}

- (BOOL)dragging {
    return holderScrollView.dragging;
}

- (BOOL)decelerating {
    return holderScrollView.decelerating;
}

- (void)setReloadIndicatoreColor:(UIColor *)color {
    refreshView.titleColor = color;
    loadMoreView.titleColor = color;
}


#pragma mark loading status
- (void)stopLoading {
    [UIView animateWithDuration:.3
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn animations:^{
                            
                            holderScrollView.contentInset = UIEdgeInsetsZero;
                            
                        } completion:^(BOOL finished) {
                            loadMoreView.state = RefreshNormal;
                            refreshView.state = RefreshNormal;

                            if (holderScrollView.contentOffset.x >=
                                holderScrollView.contentSize.width - holderScrollView.frame.size.width ) {
                                [holderScrollView setContentOffset:CGPointMake(holderScrollView.contentSize.width
                                                                               - holderScrollView.frame.size.width, 0)
                                                          animated:YES];
                            }
                            if (holderScrollView.contentOffset.x <= 0) {
                                [holderScrollView setContentOffset:CGPointZero animated:YES];
                            }
                            if ([self.delegate rowWidthForHorizonTableView:self] > 0
                                && holderScrollView.contentOffset.x < [self.delegate rowWidthForHorizonTableView:self] > 0) {
                                [holderScrollView setContentOffset:CGPointZero animated:YES];
                            }
                        }];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    
    holderScrollView.backgroundColor = backgroundColor;
    refreshView.backgroundColor = backgroundColor;
    loadMoreView.backgroundColor = backgroundColor;
}


#pragma mark uiscrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self tilePages];
    
    if (scrollView.isDragging
        && refreshView.state != RefreshLoading
        && loadMoreView.state != RefreshLoading ) {
        
        if (refreshView.state == RefreshPulling
			&& scrollView.contentOffset.x >= -40.0f
			&& scrollView.contentOffset.x < 0.0f ) {
			refreshView.state = RefreshNormal;
		} else if (refreshView.state == RefreshNormal
				   && scrollView.contentOffset.x < -40.0f ) {
			refreshView.state = RefreshPulling;
		}
        
        if ( loadMoreView.state == RefreshPulling
            && holderScrollView.contentOffset.x <= holderScrollView.contentSize.width - holderScrollView.frame.size.width + 40.0f
            && holderScrollView.contentOffset.x >
            holderScrollView.contentSize.width - holderScrollView.frame.size.width ) {
            loadMoreView.state = RefreshNormal;
        } else if (loadMoreView.state == RefreshNormal
                   && holderScrollView.contentOffset.x >
                   holderScrollView.contentSize.width - holderScrollView.frame.size.width + 40.0f ) {
            loadMoreView.state = RefreshPulling;
        }
        
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (refreshView.state == RefreshLoading || loadMoreView.state == RefreshLoading )
        return;
    
	if (holderScrollView.contentOffset.x < - 40.0f) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(horizonTableViewDidTriggerRefresh:)]) {
            [self.delegate horizonTableViewDidTriggerRefresh:self];
            refreshView.state = RefreshLoading;
            [UIView animateWithDuration:.5
                             animations:^{
                                 holderScrollView.contentInset = UIEdgeInsetsMake(0, 40.0f, 0, 0.0f);
                                 [holderScrollView setContentOffset:CGPointMake(-40, 0)
                                                           animated:NO];
                             }];
            return;
        }
	}
    
    if (holderScrollView.contentOffset.x >
        holderScrollView.contentSize.width - holderScrollView.frame.size.width + 40.0f && [loadMoreView superview]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(horizonTableViewDidTriggerLoadMore:)]) {
            [self.delegate horizonTableViewDidTriggerLoadMore:self];
            loadMoreView.state = RefreshLoading;
            [UIView animateWithDuration:.5
                             animations:^{
                                 holderScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 40.0f);
                                 [holderScrollView setContentOffset:CGPointMake(holderScrollView.contentSize.width
                                                                                - holderScrollView.frame.size.width
                                                                                + 40.0f, 0)
                                                           animated:NO];
                             }];
            return;
        }
	}
    
    if (!decelerate) {
        [self doHeavyWorkForVisibleRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (refreshView.state == RefreshLoading || loadMoreView.state == RefreshLoading )
        return;
    
    [self doHeavyWorkForVisibleRows];
}


#pragma mark recyle scroll view part
- (NSInteger)currentPageIndex {
    return (int)(((holderScrollView.contentOffset.x + holderScrollView.frame.size.width) / [self widthForRow]));
}

- (NSInteger)indexFromFrame:(CGRect)frame {
    return (int)( frame.origin.x / [self widthForRow]);
}

- (BOOL)isDisplayingCellForIndex:(NSInteger)index {
    for (UIView *cell in visibleCells)
        if ([self indexFromFrame:cell.frame] == index)
            return YES;
    return NO;
}

- (id)dequeueReusableCell {
    id cell = [recycledCells anyObject];
    if (cell) {
        [[cell retain] autorelease];
        [recycledCells removeObject:cell];
        return cell;
    } else {
        return nil;
    }
}

- (CGRect)frameForPageAtIndex:(NSInteger)index {
    return CGRectMake(index*[self widthForRow],
                      0,
                      [self widthForRow],
                      holderScrollView.frame.size.height);
}

- (void)tilePages {
    
    CGRect visibleBounds = holderScrollView.bounds;
    
    NSInteger firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / [self widthForRow]);
    int historyCount = 1;
    firstNeededPageIndex = MAX(firstNeededPageIndex - historyCount, 0);
    
    NSInteger lastNeededPageIndex = floorf((CGRectGetMaxX(visibleBounds)-1) / [self widthForRow]);
    lastNeededPageIndex  = MAX(lastNeededPageIndex+1, 1);
    lastNeededPageIndex = MIN(lastNeededPageIndex, [self numOfCells] -1);
    
    if (visibleRange.location != firstNeededPageIndex
        || visibleRange.location + visibleRange.length != lastNeededPageIndex) {
        
        visibleRange.location = firstNeededPageIndex;
        visibleRange.length = lastNeededPageIndex - firstNeededPageIndex;
        
        for (UIView *cell in visibleCells) {
            NSInteger cellIndex = [self indexFromFrame:cell.frame];
            if (cellIndex < firstNeededPageIndex || cellIndex > lastNeededPageIndex) {
                [recycledCells addObject:cell];
                [cell removeFromSuperview];
            }
        }
        [visibleCells minusSet:recycledCells];
        
        for (NSInteger i = firstNeededPageIndex; i <= lastNeededPageIndex; i++) {
            if (![self isDisplayingCellForIndex:i]) {
                UIView *cell = [self.dataSource horizonTableView:self cellForRowAtIndex:i];
                cell.frame = [self frameForPageAtIndex:i];
                [holderScrollView addSubview:cell];
                [visibleCells addObject:cell];
            }
        }
    }
    
    NSInteger curPage = [self currentPageIndex];
    if (curPage != self.currentPage && curPage > 0
        && (!self.dataSource || curPage <= [self.dataSource numberOfRowsInHorizonTableView:self])) {
        [self setValue:@(curPage) forKey:@"_currentPage"];
    }

    //NSLog(@"changed to :%d", self.currentPage);
}


@end
