//
//  JXMutableArray.h
//  Test
//
//  Created by Joe on 13-5-8.
//  Copyright (c) 2013年 Joe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JXMultiThreadObject.h"


@protocol ConcurrentMutableArrayProtocol
@optional
- (id)lastObject;
- (id)objectAtIndex:(NSUInteger)index;

- (NSUInteger)count;

- (void)addObject:(id)anObject;
- (void)removeObject:(id)anObject;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)removeLastObject;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
@end

/** this array is mutable and thread-safe 
 it provides some simple methods to operating an array 
 it is not the fastest way but quite convenient
 */
@interface ConcurrentMutableArray : JXMultiThreadObject <ConcurrentMutableArrayProtocol> {
    
}

- (NSArray *)filteredArrayUsingPredicate:(NSPredicate *)predicate;

@end
