//
//  Container.h
//  baby
//
//  Created by zhang da on 14-2-5.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

@protocol Container <NSObject>

@required

- (Model *)instanceFromDict:(NSDictionary *)dict clazz:(Class)cls;
- (void)putObject:(id)obj;
- (void)removeObject:(id)obj;

- (id)getObject:(NSPredicate *)predict clazz:(Class)cls;
- (id)getObject:(NSPredicate *)predict clazz:(Class)cls orderBy:(NSString *)sorter,...;

- (NSArray *)getObjects:(NSPredicate *)predict clazz:(Class)cls;
- (NSArray *)getObjects:(NSPredicate *)predict clazz:(Class)cls orderBy:(NSString *)sorter,...;

@end
