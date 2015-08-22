//
//  EventScrollView.m
//  kokozu
//
//  Created by zhang da on 10-10-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImagePlayerView.h"
#import "ImageView.h"

#define IMAGEVIEW_TAG 9999

@interface ImagePlayerView ()

- (void)reloadData;

@end



@implementation ImagePlayerView

- (void)dealloc {
    [self stopPlay];
    self.banners = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
	if (self) {
        pagingView = [[InfinitePagingView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        pagingView.backgroundColor = [Shared bbWhite];
        pagingView.delegate = self;
        [self addSubview:pagingView];
        
        pageControl = [[StyledPageControl alloc] initWithFrame:CGRectMake(8, frame.size.height - 20 -2, 304, 20)];
        pageControl.pageControlStyle = PageControlStyleDefault;

        pageControl.strokeSelectedColor = [UIColor whiteColor];
        pageControl.coreSelectedColor = [UIColor whiteColor];

        pageControl.strokeNormalColor = [UIColor clearColor];
        pageControl.coreNormalColor = [UIColor colorWithWhite:0 alpha:.1f];

        [self addSubview:pageControl];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touched)];
        tap.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tap];
        [tap release];
        
        [self updateLayout];
    }
    return self;
}


#pragma mark utility
- (void)updateLayout {
    if (self.banners && self.banners.count > 0) {
        [self reloadData];
    }
}

- (void)reloadData {
    [pageControl setNumberOfPages:self.banners.count];
    [pagingView reloadData];
}

- (void)startPlay {
    if (!pagingView.dragging && !pagingView.decelerating) {
        
        NSInteger currentPage = pageControl.currentPage;
        currentPage ++;
        if (currentPage >= pageControl.numberOfPages) {
            currentPage = 0;
        }
        
        [pagingView scrollToRowAtIndex:currentPage animated:YES];
    }
    
    [self performSelector:@selector(startPlay)
                   withObject:nil
                   afterDelay:5
                      inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}

- (void)stopPlay {
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(startPlay)
                                               object:nil];
}


#pragma mark infinite paging view delegate and datasource
- (void)configPage:(UIView *)page forIndex:(NSInteger)index {
    ImageView *imageView = (ImageView *)[page viewWithTag:IMAGEVIEW_TAG];
    if (!imageView) {
        imageView = [[ImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        imageView.tag = IMAGEVIEW_TAG;
        [page addSubview:imageView];
        [imageView release];
    }
    if ([self.banners count] > index) {
        imageView.imagePath = [self.banners objectAtIndex:index];
    }
}

- (NSInteger)numberOfPages {
    return self.banners.count;
}

- (float)widthForPage {
    return 320;
}

- (void)touched {
    if (self.delegate && [self.delegate respondsToSelector:@selector(handleTouchAtIndex:)]) {
        [self.delegate handleTouchAtIndex:pageControl.currentPage];
    }
}

- (void)selectedPageChangedTo:(NSInteger)newPage {
    NSInteger page = newPage - 1;
    page = MAX(page, 0);
    page = MIN(page, pageControl.numberOfPages);
    
    pageControl.currentPage = page;
}


@end