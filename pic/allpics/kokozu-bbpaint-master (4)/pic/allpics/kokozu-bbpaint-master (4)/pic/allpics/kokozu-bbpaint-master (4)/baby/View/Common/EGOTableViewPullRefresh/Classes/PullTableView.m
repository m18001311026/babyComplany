//
//  PullTableView.m
//  TableViewPull
//
//  Created by Emre Berge Ergenekon on 2011-07-30.
//  Copyright 2011 Emre Berge Ergenekon. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "PullTableView.h"

@interface PullTableView (Private) <UIScrollViewDelegate>
- (void) config;
- (void) configDisplayProperties;
@end


@implementation PullTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.hasMore = YES;
        [self config];
    }
    return self;
}

- (void)dealloc {
    self.pullArrowImage = nil;
    self.pullBackgroundColor = nil;
    self.pullTextColor = nil;
    self.pullLastRefreshDate = nil;
    
    [refreshView release];
    [loadMoreView release];
    
    [delegateInterceptor release];
    delegateInterceptor = nil;
    
    [placeholder release];

    self.pullDelegate = nil;
    
    [super dealloc];
}


# pragma mark - Custom view configuration
- (void) config {
    /* Message interceptor to intercept scrollView delegate messages */
    delegateInterceptor = [[MessageInterceptor alloc] init];
    delegateInterceptor.middleMan = self;
    delegateInterceptor.receiver = self.delegate;
    super.delegate = (id)delegateInterceptor;
    
    /* Status Properties */
    _isRefreshing = NO;
    _isLoadingMore = NO;
    
    /* Refresh View */    
    refreshView = [[SRRefreshView alloc] initWithHeight:44];
    refreshView.delegate = self;
    refreshView.upInset = 0;
    refreshView.slimeMissWhenGoingBack = YES;
    refreshView.slime.bodyColor = [Shared bbGray];
    refreshView.slime.skinColor = [Shared bbGray];
    refreshView.slime.lineWith = 1;
    refreshView.slime.shadowBlur = 0;
    refreshView.slime.shadowColor = nil;
    [self addSubview:refreshView];
    
    /* Load more view init */
    loadMoreView = [[LoadMoreTableFooterView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
    loadMoreView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    loadMoreView.delegate = self;
    [self addSubview:loadMoreView];
    
    placeholder = [[UILabel alloc] init];
    placeholder.font = [UIFont systemFontOfSize:16];
    placeholder.textColor = [UIColor grayColor];
    placeholder.textAlignment = NSTextAlignmentCenter;
    placeholder.numberOfLines = 0;
    placeholder.backgroundColor = [UIColor clearColor];
    [self addSubview:placeholder];
}


# pragma mark - View changes
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat visibleTableDiffBoundsHeight = (self.bounds.size.height - MIN(self.bounds.size.height, self.contentSize.height));
    
    CGRect loadMoreFrame = loadMoreView.frame;
    loadMoreFrame.origin.y = self.contentSize.height + visibleTableDiffBoundsHeight;
    loadMoreView.frame = loadMoreFrame;
}


#pragma mark - Preserving the original behaviour
- (void)setDelegate:(id<UITableViewDelegate>)delegate {
    if(delegateInterceptor) {
        super.delegate = nil;
        delegateInterceptor.receiver = delegate;
        super.delegate = (id)delegateInterceptor;
    } else {
        super.delegate = delegate;
    }
}

- (void)reloadData {
    [super reloadData];
    // Give the footers a chance to fix it self.
    [loadMoreView egoRefreshScrollViewDidScroll:self];
}

- (void)stopLoading {
    self.isRefreshing = NO;
    self.isLoadingMore = NO;
}


#pragma mark - Status Propreties
- (void)setIsRefreshing:(BOOL)isRefreshing {
    if (_isRefreshing != isRefreshing) {
        _isRefreshing = isRefreshing;
        
        if (_isRefreshing) {
            //[refreshView startAnimatingWithScrollView:self];
        } else {
            [refreshView endRefresh];
            
            UIEdgeInsets currentInsets = self.contentInset;
            currentInsets.top = 0;
            self.contentInset = currentInsets;
        }
    }
}

- (void)setIsLoadingMore:(BOOL)isLoadingMore {
    if(!_isLoadingMore && isLoadingMore) {
        // If not allready loading more start refreshing
        [loadMoreView startAnimatingWithScrollView:self];
        _isLoadingMore = YES;
    } else if(_isLoadingMore && !isLoadingMore) {
        [loadMoreView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
        _isLoadingMore = NO;
    }
}


#pragma mark - Display properties
- (void)configDisplayProperties {
    [refreshView setBackgroundColor:self.pullBackgroundColor];
    [loadMoreView setBackgroundColor:self.pullBackgroundColor textColor:self.pullTextColor arrowImage:self.pullArrowImage];
}

- (void)setPullArrowImage:(UIImage *)aPullArrowImage {
    if(aPullArrowImage != _pullArrowImage) {
        [_pullArrowImage release];
        _pullArrowImage = [aPullArrowImage retain];
        [self configDisplayProperties];
    }
}

- (void)setPullBackgroundColor:(UIColor *)aColor {
    if(aColor != _pullBackgroundColor) {
        [_pullBackgroundColor release];
        _pullBackgroundColor = [aColor retain];
        [self configDisplayProperties];
    } 
}

- (void)setPullTextColor:(UIColor *)aColor {
    if(aColor != _pullTextColor) {
        [_pullTextColor release];
        _pullTextColor = [aColor retain];
        [self configDisplayProperties];
    } 
}

- (void)setPullLastRefreshDate:(NSDate *)aDate {
    if(aDate != _pullLastRefreshDate) {
        [_pullLastRefreshDate release];
        _pullLastRefreshDate = [aDate retain];
        //[refreshView refreshLastUpdatedDate];
    }
}

- (void)showPlaceHolder:(NSString *)text {
    if (text) {
        placeholder.frame = CGRectMake(10, (self.frame.size.height - 60)/2, self.frame.size.width - 20, 60);
        [self addSubview:placeholder];
        placeholder.text = text;
    } else {
        placeholder.text = nil;
        [placeholder removeFromSuperview];
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //[refreshView egoRefreshScrollViewDidScroll:scrollView];
    [refreshView scrollViewDidScroll];
    [loadMoreView egoRefreshScrollViewDidScroll:scrollView];
    
    // Also forward the message to the real delegate
    if ([delegateInterceptor.receiver
         respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [delegateInterceptor.receiver scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    [refreshView scrollViewDidEndDraging];
    //[refreshView egoRefreshScrollViewDidEndDragging:scrollView];
    if (self.hasMore) {
        [loadMoreView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    
    // Also forward the message to the real delegate
    if ([delegateInterceptor.receiver
         respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [delegateInterceptor.receiver scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //[refreshView egoRefreshScrollViewWillBeginDragging:scrollView];
    
    // Also forward the message to the real delegate
    if ([delegateInterceptor.receiver
         respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [delegateInterceptor.receiver scrollViewWillBeginDragging:scrollView];
    }
}


#pragma mark - EGORefreshTableHeaderDelegate
#pragma mark - slimeRefresh delegate
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView {
    if (!self.isRefreshing && !self.isLoadingMore) {
        self.isRefreshing = YES;
        [self.pullDelegate pullTableViewDidTriggerRefresh:self];
    }
}


- (void)egoRefreshTableHeaderDidTriggerRefresh:(RefreshTableHeaderView*)view {
    if (!self.isRefreshing && !self.isLoadingMore) {
        self.isRefreshing = YES;
        [self.pullDelegate pullTableViewDidTriggerRefresh:self];
    }
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(RefreshTableHeaderView*)view {
    return self.pullLastRefreshDate;
}


#pragma mark - LoadMoreTableViewDelegate
- (void)loadMoreTableFooterDidTriggerLoadMore:(LoadMoreTableFooterView *)view {
    if (!self.isRefreshing && !self.isLoadingMore) {
        self.isLoadingMore = YES;
        [self.pullDelegate pullTableViewDidTriggerLoadMore:self];
    }
}


@end
