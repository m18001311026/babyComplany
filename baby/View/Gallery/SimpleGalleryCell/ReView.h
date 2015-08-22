//
//  ReViews.h
//  baby
//
//  Created by zhang da on 15/7/12.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ReView;

@protocol ReViewDelegate <NSObject>

@required
//- (void)newRe:(long)galleryId;
- (void)showRe:(long)galleryId;
- (void)showAllRe:(long)galleryId;

@end


@interface ReView : UIView {
    NSMutableArray *reViews;
    NSMutableArray *reTitles;
    NSMutableArray *res;
}

@property (nonatomic, assign) long galleryId;
@property (nonatomic, assign) id<ReViewDelegate> delegate;
@end
