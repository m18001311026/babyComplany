//
//  AccountViewController.h
//  baby
//
//  Created by zhang da on 14-3-3.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "BBViewController.h"
#import "PullTableView.h"
#import "SimpleSegment.h"
#import "GridGalleryCell.h"
#import "AccountView.h"
#import "CommentCell.h"

@interface UserViewController : BBViewController
<UITableViewDataSource, UITableViewDelegate, SimpleSegmentDelegate, PullTableViewDelegate,
GridGalleryCellDelegate, AccountViewDelegate, CommentCellDelegate>{
    
    int currentPage;
    NSMutableArray *galleries, *comments;

    PullTableView *galleryTable;
    SimpleSegment *contentType;
    AccountView *header;
    
}

- (id)initWithUser:(long)userId;

@end
