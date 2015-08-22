//
//  MaterialView.h
//  baby
//
//  Created by zhang da on 15/6/30.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HorizonTableView.h"

@protocol MaterialViewDelegate <NSObject>

@required
- (void)selectMaterial:(long)materialId atIndex:(NSInteger)index;

@end


@interface MaterialView : UIView <HorizonTableViewDatasource, HorizonTableViewDelegate> {
    HorizonTableView *holder;
    NSMutableArray *materialViews;
    NSMutableArray *materials;
    int _currentPage;
}

@property(nonatomic, assign) id<MaterialViewDelegate> delegate;
@property(nonatomic, assign) long categoryId;

- (void)loadMaterials;

@end
