//
//  PullToRefreshView.h
//  simpleread
//
//  Created by zhang da on 10-10-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

typedef enum {
	RefreshPulling,
	RefreshNormal,
	RefreshLoading
} RefreshState;

@interface PullToRefreshView : UIView {
	
	RefreshState state;
    UIColor *titleColor;
    
    UIActivityIndicatorView *activityView;
}

@property (nonatomic, retain) NSDate *lastUpdatedDate;
@property (nonatomic, retain) UIColor *titleColor;
@property (nonatomic) RefreshState state;

@end