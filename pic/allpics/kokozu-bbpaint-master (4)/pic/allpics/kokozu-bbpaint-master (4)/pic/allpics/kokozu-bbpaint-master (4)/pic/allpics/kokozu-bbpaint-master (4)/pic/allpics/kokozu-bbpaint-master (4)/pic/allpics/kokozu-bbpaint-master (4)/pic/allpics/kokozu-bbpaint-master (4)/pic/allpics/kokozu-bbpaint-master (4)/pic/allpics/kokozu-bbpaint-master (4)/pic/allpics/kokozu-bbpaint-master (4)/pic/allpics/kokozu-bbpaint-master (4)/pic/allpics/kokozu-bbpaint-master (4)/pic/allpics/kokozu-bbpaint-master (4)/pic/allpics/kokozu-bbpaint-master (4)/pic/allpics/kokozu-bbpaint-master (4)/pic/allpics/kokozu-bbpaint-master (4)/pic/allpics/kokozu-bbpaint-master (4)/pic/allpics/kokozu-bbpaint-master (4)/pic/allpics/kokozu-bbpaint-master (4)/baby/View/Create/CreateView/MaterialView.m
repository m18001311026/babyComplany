//
//  MaterialView.m
//  baby
//
//  Created by zhang da on 15/6/30.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import "MaterialView.h"
#import "ImageView.h"
#import "Material.h"
#import "HorizonTableView.h"
#import "HorizonMaterialCell.h"

#import "MaterialTask.h"
#import "TaskQueue.h"

#define BTN_WIDTH 44
#define PAGESIZE 50

@implementation MaterialView

- (void)dealloc {
    [materials release];
    self.delegate = nil;
    
    [super dealloc];
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        materialViews = [[NSMutableArray alloc] init];

        holder = [[HorizonTableView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        holder.backgroundColor = [UIColor whiteColor];
        holder.delegate = self;
        holder.dataSource = self;
        [holder setReloadIndicatoreColor:[UIColor blackColor]];
        [self addSubview:holder];
        [holder release];
        
        materials = [[NSMutableArray alloc] init];
        _currentPage = 1;
    }
    return self;
}


#pragma ui events
- (void)loadMaterials {
    if (_categoryId < 1) {
        return;
    }
    
    MaterialTask *task = [[MaterialTask alloc] initGetMaterialForCategory:self.categoryId
                                                                     page:_currentPage
                                                                    count:PAGESIZE];
    task.logicCallbackBlock = ^(bool succeeded, id userInfo) {
        if (_currentPage == 1) {
            [materials removeAllObjects];
        }
        
        if (succeeded) {
            NSArray *galleries = (NSArray *)userInfo;
            [materials addObjectsFromArray:galleries];
            if ([((NSArray *)userInfo) count] < PAGESIZE) {
                holder.hasMore = NO;
            } else {
                holder.hasMore = YES;
            }
        }
        
        [holder reloadData];
        [holder stopLoading];
    };
    [TaskQueue addTaskToQueue:task];
    [task release];
}


#pragma HorizonTableViewDelegate
- (int)rowWidthForHorizonTableView:(HorizonTableView *)tableView {
    return BTN_WIDTH;
}

- (void)horizonTableView:(HorizonTableView *)tableView didSelectRowAtIndex:(NSInteger)index {
    if (self.delegate) {
        long materialId = [[materials objectAtIndex:index] longValue];
        [self.delegate selectMaterial:materialId atIndex:index];
    }
}

- (void)horizonTableView:(HorizonTableView *)tableView
    loadHeavyDataForCell:(UIView *)cell
                 atIndex:(NSInteger)index {
    
}


#pragma HorizonTableViewDatasource
- (NSInteger)numberOfRowsInHorizonTableView:(HorizonTableView *)tableView {
    return materials.count;
}

- (UIView *)horizonTableView:(HorizonTableView *)tableView cellForRowAtIndex:(NSInteger)index {
    HorizonMaterialCell *cell = [tableView dequeueReusableCell];
    if (!cell) {
        cell = [[[HorizonMaterialCell alloc] initWithFrame:CGRectMake(0, 0, BTN_WIDTH, BTN_WIDTH)] autorelease];
    }
    long materialId = [[materials objectAtIndex:index] longValue];
    Material *m = [Material getMaterialWithId:materialId];
    cell.picturePath = m.fodderPicture;
    [cell updateLayout];
    return cell;
}


#pragma mark horizon table view delegate
- (void)horizonTableViewDidTriggerRefresh:(HorizonTableView *)pullTableView {
    _currentPage = 1;
    [self loadMaterials];
}

- (void)horizonTableViewDidTriggerLoadMore:(HorizonTableView *)pullTableView {
    _currentPage ++;
    [self loadMaterials];
}


@end
