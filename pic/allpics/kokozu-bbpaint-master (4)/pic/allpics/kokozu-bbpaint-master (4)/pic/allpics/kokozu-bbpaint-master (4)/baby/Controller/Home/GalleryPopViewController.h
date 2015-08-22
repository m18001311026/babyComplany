//
//  HomeViewController.h
//  baby
//
//  Created by zhang da on 14-3-3.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "TabbarSubviewController.h"
#import "PullTableView.h"
#import "SimpleSegment.h"
#import "EditView.h"

#import "CommentCell.h"
#import "ThumbCell.h"
#import "UserCell.h"

@interface GalleryPopViewController : BBViewController
<UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate, SimpleSegmentDelegate, UIScrollViewDelegate,
CommentCellDelegate, ThumbCellDelegate, UserCellDelegate, EditViewDelegate> {
    
    int currentPage;
    PullTableView *holderTable;
    SimpleSegment *contentType;
    EditView *editView;

    NSMutableArray *likes, *comments, *res;
}

- (id)initWithGallery:(long)galleryId;

@end
