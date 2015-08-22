//
//  CategoryView.m
//  baby
//
//  Created by zhang da on 15/6/30.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import "CategoryView.h"
#import "UIButtonExtra.h"

#import "MaterialTask.h"
#import "TaskQueue.h"

#import "MCategory.h"
#import "AudioPlayer.h"
#import "MemContainer.h"

#define PAGESIZE 12
#define COL_CNT 4

@implementation CategoryView

- (void)dealloc {
    [categories release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Custom initialization
        self.backgroundColor = [UIColor clearColor];
        
        UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 310, frame.size.height)];
        bg.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
        bg.layer.cornerRadius = 3;
        bg.layer.masksToBounds = YES;
        [self addSubview:bg];
        [bg release];
        
        galleryTable = [[PullTableView alloc] initWithFrame:CGRectMake(10, 44, 300, 300)
                                                      style:UITableViewStylePlain];
        galleryTable.pullDelegate = self;
        galleryTable.delegate = self;
        galleryTable.dataSource = self;
        galleryTable.backgroundColor = [UIColor clearColor];
        galleryTable.pullBackgroundColor = [UIColor colorWithWhite:.8 alpha:1];
        [galleryTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self addSubview:galleryTable];
        [galleryTable release];
        
        UIButton *closeBtn = [UIButton simpleButton:@"关闭" y:2];
        closeBtn.frame = CGRectMake(280, 2, 35, 35);
        [closeBtn setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeBtn];

        UILabel *lab = [[UILabel alloc] init];
        lab.text = @"素材库";
        lab.font = [UIFont systemFontOfSize:20];
        lab.textColor = [UIColor colorWithRed:238/255.0 green:152/255.0 blue:0/255.0 alpha:1.0 ];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.frame = CGRectMake((320-80)/2, 10, 80, 35);
        [self addSubview:lab];
        [lab release];
        
        categories = [[NSMutableArray alloc] initWithCapacity:0];
        currentPage = 1;
        [self loadCategory];
    }
    return self;
}


#pragma ui event
- (void)loadCategory {
    MaterialTask *task = [[MaterialTask alloc] initGetCategoryAtPage:currentPage count:PAGESIZE];
    task.logicCallbackBlock = ^(bool succeeded, id userInfo) {
        if (currentPage == 1) {
            [categories removeAllObjects];
        }
        
        if (succeeded) {
            [categories addObjectsFromArray:(NSArray *)userInfo];
            if ([((NSArray *)userInfo) count] < PAGESIZE) {
                galleryTable.hasMore = NO;
            } else {
                galleryTable.hasMore = YES;
            }
        }
        
        [galleryTable reloadData];
        [galleryTable stopLoading];
    };
    [TaskQueue addTaskToQueue:task];
    [task release];
}

- (void)close {
    [self removeFromSuperview];
}


#pragma table view section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return categories.count/COL_CNT + (categories.count%COL_CNT>0? 1: 0);
}

- (void)configCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    for (int i = 0; i < COL_CNT; i++) {
        CategoryCell *gCell = (CategoryCell *)cell;
        gCell.row = indexPath.row;
        if (indexPath.row*COL_CNT + i < categories.count) {
            long gId = [[categories objectAtIndex:indexPath.row*COL_CNT + i] longValue];
            MCategory *g = [MCategory getCategoryWithId:gId];
            [gCell setImagePath:g.typePicture atCol:i];
            [gCell setTitle:g.typeName atCol:i];
        } else {
            [gCell setImagePath:nil atCol:i];
            [gCell setTitle:nil atCol:i];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"CategoryCell";
    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[[CategoryCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:cellId
                                              colCnt:COL_CNT] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    [self configCell:cell atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self close];
}

- (void)galleryTouchedAtRow:(NSInteger)row andCol:(NSInteger)col {
    NSInteger index = row*COL_CNT + col;
    if (index < categories.count) {
        long categoryId = [[categories objectAtIndex:index] longValue];
        if (self.delegate && [self.delegate respondsToSelector:@selector(categoryTouched:)]) {
            [self.delegate categoryTouched:categoryId];
        }
    }
}


#pragma mark pull table view delegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView {
    currentPage = 1;
    [self loadCategory];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView {
    currentPage ++;
    [self loadCategory];
}


@end
