//
//  Material.h
//  baby
//
//  Created by zhang da on 15/7/19.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import "Model.h"

@interface Material : Model

@property (nonatomic, assign) long _id;
@property (nonatomic, assign) long categoryId;
@property (nonatomic, retain) NSString *fodderPicture;

+ (Material *)getMaterialWithId:(long)_id;
+ (NSArray *)getMaterialsForCategory:(long)categoryId;

@end
