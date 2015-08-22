//
//  CategoryView.h
//  baby
//
//  Created by zhang da on 15/6/30.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullTableView.h"
#import "CategoryCell.h"

@protocol CategoryViewDelegate <NSObject>
- (void)categoryTouched:(long)categoryId;
@end


@interface CategoryView : UIView
<UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate, CategoryCellDelegate> {
    PullTableView *galleryTable;
    NSMutableArray *categories;
    int currentPage;
}

@property (nonatomic, assign) id<CategoryViewDelegate> delegate;

@end
