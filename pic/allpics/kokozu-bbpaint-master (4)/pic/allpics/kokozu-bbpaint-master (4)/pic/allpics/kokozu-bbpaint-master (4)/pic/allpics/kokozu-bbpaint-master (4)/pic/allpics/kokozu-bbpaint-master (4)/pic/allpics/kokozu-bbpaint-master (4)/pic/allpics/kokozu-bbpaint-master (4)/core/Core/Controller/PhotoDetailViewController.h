//
//  PhotoDetailViewController.h
//  phonebook
//
//  Created by da zhang on 11-3-15.
//  Copyright 2011 wozai llc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBViewController.h"

@interface PhotoDetailViewController : BBViewController <UIScrollViewDelegate>{
	UIScrollView *imageScrollView;
	NSString *imageURL;
    	
	//NSTimer *hideTimer;
	BOOL loaded;
}

@property (nonatomic, retain) UIScrollView *imageScrollView;
@property (nonatomic, retain) NSString *imageURL;

@end
