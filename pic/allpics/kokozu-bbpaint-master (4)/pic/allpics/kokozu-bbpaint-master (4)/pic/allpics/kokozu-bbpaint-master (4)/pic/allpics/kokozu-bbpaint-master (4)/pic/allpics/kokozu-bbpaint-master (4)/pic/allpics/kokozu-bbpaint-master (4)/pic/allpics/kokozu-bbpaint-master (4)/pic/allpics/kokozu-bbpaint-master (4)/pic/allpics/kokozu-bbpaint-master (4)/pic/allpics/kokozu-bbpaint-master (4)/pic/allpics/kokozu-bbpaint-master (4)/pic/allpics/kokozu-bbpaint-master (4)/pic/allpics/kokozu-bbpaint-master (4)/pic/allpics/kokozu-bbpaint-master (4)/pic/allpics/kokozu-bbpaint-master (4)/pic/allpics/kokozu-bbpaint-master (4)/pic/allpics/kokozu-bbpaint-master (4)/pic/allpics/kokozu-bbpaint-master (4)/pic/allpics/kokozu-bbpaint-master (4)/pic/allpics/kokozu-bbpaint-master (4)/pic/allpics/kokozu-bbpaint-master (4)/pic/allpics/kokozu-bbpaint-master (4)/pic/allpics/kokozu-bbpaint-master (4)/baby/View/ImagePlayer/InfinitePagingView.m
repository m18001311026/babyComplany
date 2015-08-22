//
//  InfinitePagingView.m
//  simpleread
//
//  Created by zhang da on 11-4-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "InfinitePagingView.h"

#define HISTORY_CNT 2
#define BASIC_TAG 111111

@interface InfinitePagingView (Private)
- (void)tilePages;
- (void)refreshVisiblePages;

- (UIView *)dequeueRecycledPage;
- (CGRect)frameForPageAtIndex:(NSInteger)index;
@end


@implementation InfinitePagingView


@synthesize delegate = _delegate;
@synthesize currentPage = _currentPage;



- (void)setCurrentPage:(NSInteger)currentPage {
    if (currentPage != _currentPage) {
        _currentPage = currentPage;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(selectedPageChangedTo:)]) {
            [self.delegate selectedPageChangedTo:currentPage];
        }
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {        
        self.backgroundColor = [UIColor blackColor];
        
        holderScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        holderScrollView.showsHorizontalScrollIndicator = NO;
        holderScrollView.delegate = self;
        holderScrollView.pagingEnabled = YES;
        [self addSubview:holderScrollView];
        [holderScrollView release];

        visiblePages = [[NSMutableSet alloc] init];
        recycledPages = [[NSMutableSet alloc] init];
        
        [self tilePages];
    }
    return self;
}

- (BOOL)dragging {
    return holderScrollView.dragging;
}

- (BOOL)decelerating {
    return holderScrollView.decelerating;
}

- (void)dealloc {
    [visiblePages release];
    [recycledPages release];
    
    [super dealloc];
}



#pragma mark uiscrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {	
    [self tilePages];
}



#pragma mark recyle scroll view part
- (UIView *)pageAtIndex:(NSInteger)index {
    UIView *page = [self dequeueRecycledPage];
    if (!page) 
        page = [[[UIView alloc] init] autorelease];
    if ([self.delegate numberOfPages]) {
        @try {
            [self.delegate configPage:page forIndex:index];
        }
        @catch (NSException *exception) {

        }
        @finally {
            
        }
    }
    page.frame = [self frameForPageAtIndex:index];
    page.tag = BASIC_TAG + index;
    return page;
}



#pragma mark LandscapeTableView
- (void)scrollToRowAtIndex:(NSInteger)index animated:(BOOL)animated {
    NSInteger maxPages = [self.delegate numberOfPages];
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

- (void)reloadData {
    holderScrollView.contentSize = CGSizeMake( [self.delegate widthForPage]*[self.delegate numberOfPages], 
                                              holderScrollView.frame.size.height );
    [self refreshVisiblePages];
    [self tilePages];
}

- (int)currentPageIndex {
    //DLog(@"(%f + %f) / %f", holderScrollView.contentOffset.x , holderScrollView.frame.size.width, [self.delegate widthForPage]);
    return (int)((holderScrollView.contentOffset.x + holderScrollView.frame.size.width)/ [self.delegate widthForPage]);
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
    for (UIView *page in visiblePages)
        if (page.tag - BASIC_TAG == index)
            return YES;
    return NO;
}

- (UIView *)dequeueRecycledPage {
    UIView *page = [recycledPages anyObject];
    if (page) {
        [[page retain] autorelease];
        [recycledPages removeObject:page];
    }
    return page;
}

- (CGRect)frameForPageAtIndex:(NSInteger)index {
    return CGRectMake(index*[self.delegate widthForPage], 
                      0, 
                      [self.delegate widthForPage], 
                      holderScrollView.frame.size.height);
}

- (void)tilePages {
    CGRect visibleBounds = holderScrollView.bounds;
    NSInteger firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / [self.delegate widthForPage]);
    NSInteger lastNeededPageIndex = floorf((CGRectGetMaxX(visibleBounds)-1) / [self.delegate widthForPage]);
    firstNeededPageIndex = MAX(firstNeededPageIndex - HISTORY_CNT, 0);
    lastNeededPageIndex = MAX(lastNeededPageIndex + 2, 2);
    lastNeededPageIndex = MIN(lastNeededPageIndex, [self.delegate numberOfPages] - 1);
    
    // Recycle unneeded controllers
    for (UIView *page in visiblePages) {
        if (page.tag - BASIC_TAG < firstNeededPageIndex || page.tag - BASIC_TAG > lastNeededPageIndex) {
            [recycledPages addObject:page];
            [page removeFromSuperview];
        }
    }
    [visiblePages minusSet:recycledPages];
    
    self.currentPage = [self currentPageIndex];
    
    // Add missing pages
    for (NSInteger i = firstNeededPageIndex; i <= lastNeededPageIndex; i++) {
        if (![self isDisplayingPageForIndex:i]) {
            UIView *page = [self pageAtIndex:i];
            [holderScrollView addSubview:page];
            [visiblePages addObject:page];
        }
    }
}

- (void)refreshVisiblePages {
    NSInteger pageNum = [self.delegate numberOfPages];
    for (UIView *page in visiblePages) {
        if (pageNum > 0 && page.tag - BASIC_TAG < pageNum) {
            [self.delegate configPage:page forIndex:page.tag - BASIC_TAG];
        }
    }
}


@end
