//
//  CategoryTask.h
//  baby
//
//  Created by zhang da on 15/7/19.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import "BBNetworkTask.h"

@interface MaterialTask : BBNetworkTask

- (id)initGetCategoryAtPage:(int)page count:(int)count;
- (id)initGetMaterialForCategory:(long)categoryId page:(int)page count:(int)count;

@end
