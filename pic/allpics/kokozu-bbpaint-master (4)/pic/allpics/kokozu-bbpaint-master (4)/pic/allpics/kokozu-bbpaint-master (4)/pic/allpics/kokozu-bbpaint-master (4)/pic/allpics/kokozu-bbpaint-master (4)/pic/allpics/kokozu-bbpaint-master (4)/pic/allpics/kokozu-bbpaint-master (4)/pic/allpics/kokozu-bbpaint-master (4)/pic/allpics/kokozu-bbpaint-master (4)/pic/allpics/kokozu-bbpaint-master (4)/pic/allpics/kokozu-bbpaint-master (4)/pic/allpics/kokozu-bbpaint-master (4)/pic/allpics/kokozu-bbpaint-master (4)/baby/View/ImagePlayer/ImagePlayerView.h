//
//  EventScrollView.h
//  kokozu
//
//  Created by zhang da on 10-10-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "InfinitePagingView.h"
#import "StyledPageControl.h"

@protocol ImagePlayerViewDelegate <NSObject>

@optional
- (void)handleTouchAtIndex:(NSInteger)index;

@end



@interface ImagePlayerView: UIView < InfinitePagingViewDelegate > {
	
    InfinitePagingView *pagingView;
    StyledPageControl *pageControl;
    
}

@property (nonatomic, assign) id <ImagePlayerViewDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *banners;

- (void)updateLayout;
- (void)startPlay;
- (void)stopPlay;


@end