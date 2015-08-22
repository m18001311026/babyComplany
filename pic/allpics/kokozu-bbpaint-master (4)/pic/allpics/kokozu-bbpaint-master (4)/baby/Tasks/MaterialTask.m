//
//  CategoryTask.m
//  baby
//
//  Created by zhang da on 15/7/19.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import "ConfManager.h"
#import "MaterialTask.h"
#import "MCategory.h"
#import "Material.h"
#import "MemContainer.h"
#import "NSDictionaryExtra.h"

@implementation MaterialTask

- (id)initGetCategoryAtPage:(int)page count:(int)count {
    self = [super initWithUrl:[NSString stringWithFormat:@"%@/type/find.do", SERVERURL]
                       method:GET
                      session:[ConfManager me].sessionId];
    if (self) {
        [self addParameter:@"pageNow" value:[NSString stringWithFormat:@"%d", page]];
        [self addParameter:@"count" value:[NSString stringWithFormat:@"%d", count]];
        
        self.responseCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                NSDictionary *dict = (NSDictionary *)userInfo;
                NSArray *categories = [dict objForKey:@"type"];
                
                if (categories && categories.count > 0) {
                    NSMutableArray *categoryIds = [[NSMutableArray alloc] initWithCapacity:0];
                    for (NSDictionary *categoryDict in categories) {
                        MCategory *c = (MCategory *)[[MemContainer me] instanceFromDict:categoryDict clazz:[MCategory class]];
                        [categoryIds addObject:@(c._id)];
                    }
                    [self doLogicCallBack:YES info:[categoryIds autorelease]];
                } else {
                    [self doLogicCallBack:YES info:nil];
                }
            } else {
                [self doLogicCallBack:NO info:userInfo];
            }
        };
    }
    return self;
}

- (id)initGetMaterialForCategory:(long)categoryId page:(int)page count:(int)count {
    self = [super initWithUrl:[NSString stringWithFormat:@"%@/fodder/find.do", SERVERURL]
                       method:GET
                      session:[ConfManager me].sessionId];
    if (self) {
        [self addParameter:@"typeId" value:[NSString stringWithFormat:@"%ld", categoryId]];
        [self addParameter:@"pageNow" value:[NSString stringWithFormat:@"%d", page]];
        [self addParameter:@"count" value:[NSString stringWithFormat:@"%d", count]];
        
        self.responseCallbackBlock = ^(bool succeeded, id userInfo) {
            if (succeeded) {
                NSDictionary *dict = (NSDictionary *)userInfo;
                NSArray *materials = [dict objForKey:@"fodder"];
                
                if (materials && materials.count > 0) {
                    NSMutableArray *materialIds = [[NSMutableArray alloc] initWithCapacity:0];
                    for (NSDictionary *materialDict in materials) {
                        Material *c = (Material *)[[MemContainer me] instanceFromDict:materialDict clazz:[Material class]];
                        [materialIds addObject:@(c._id)];
                    }
                    [self doLogicCallBack:YES info:[materialIds autorelease]];
                } else {
                    [self doLogicCallBack:YES info:nil];
                }
            } else {
                [self doLogicCallBack:NO info:userInfo];
            }
        };
    }
    return self;
}

@end
