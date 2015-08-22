//
//  Category.h
//  baby
//
//  Created by zhang da on 15/7/19.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import "Model.h"

@interface MCategory : Model

@property (nonatomic, assign) long _id;
@property (nonatomic, retain) NSString *typeName;
@property (nonatomic, retain) NSString *typePicture;

+ (MCategory *)getCategoryWithId:(long)_id;

@end
