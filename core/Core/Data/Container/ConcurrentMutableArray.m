//
//  ConcurrentMutableArray.m
//  Test
//
//  Created by Joe on 13-5-8.
//  Copyright (c) 2013年 Joe. All rights reserved.
//

#import "ConcurrentMutableArray.h"

@implementation ConcurrentMutableArray

- (id)init {
    self = [super init];
    if (self) {
        self.container = [NSMutableArray array];
    }
    return self;
}

- (NSArray *)filteredArrayUsingPredicate:(NSPredicate *)predicate {
    
    NSArray *array = [NSArray arrayWithArray:(NSArray *)self.container];
    return [array filteredArrayUsingPredicate:predicate];
    
}

@end
