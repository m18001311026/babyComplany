//
//  HomeViewController.h
//  baby
//
//  Created by zhang da on 14-3-3.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "PullTableView.h"
#import "SimpleSegment.h"
#import "SimpleGalleryCell.h"
#import "BBViewController.h"

@interface GalleryDetailViewController : BBViewController
<UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate, SimpleSegmentDelegate,
UIScrollViewDelegate,
SimpleGalleryCellDelegate, UserInfoViewDelegate, CommentViewDelegate, ReViewDelegate> {
    
    PullTableView *galleryTable;
    UIButton *deleteBtn;
}

- (id)initWithGalleryId:(long)galleryId;

@end
