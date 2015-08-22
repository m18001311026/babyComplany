//
//  MemContainer.m
//  baby
//
//  Created by zhang da on 14-2-5.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "MemContainer.h"
#import "ConcurrentMutableArray.h"


@implementation MemContainer

static MemContainer *_me = nil;

+ (MemContainer *)me {
    if (!_me) {
        @synchronized([MemContainer class]) {
            if (!_me) {
                NSLog(@"memcontainer init");
                _me = [[MemContainer alloc] init];
            }
        }
    }
    return _me;
}

- (void)dealloc {
    self.holder = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        self.holder = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)putObject:(id)obj {
    if (obj) {
        ConcurrentMutableArray *container = [self getContainer:NSStringFromClass([obj class])];
        [container addObject:obj];
    }
}

- (void)removeObject:(id)obj {
    if (obj) {
        ConcurrentMutableArray *container = [self getContainer:NSStringFromClass([obj class])];
        [container removeObject:obj];
    }
}

- (Model *)instanceFromDict:(NSDictionary *)dict clazz:(Class)cls {
    if (!dict || (NSNull *)dict == [NSNull null]) {
        return nil;
    }
    if ([cls isSubclassOfClass:[Model class]] && [cls primaryKey]) {
        NSString *primaryKey = [[cls mapping] objectForKey:[cls primaryKey]];
        if (!primaryKey) {
            primaryKey = [cls primaryKey];
        }
        NSObject *value = [dict objectForKey:primaryKey];
        Model *current = [self getObject:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ = %@", [cls primaryKey], @"%@"], value]
                                   clazz:cls];
        if (!current) {
            Model *new = [cls instanceFromDict:dict];
            [self putObject:new];
            return new;
        } else {
            [current updateFromDict:dict updateType:Replace];
            return current;
        }
    }
    return nil;
}

- (id)getObject:(NSPredicate *)predict clazz:(Class)cls {
    NSArray *array = [[self getContainer:NSStringFromClass(cls)]
            filteredArrayUsingPredicate:predict];
    if ([array count]) {
        return [array objectAtIndex:0];
    }
    return nil;
}

- (id)getObject:(NSPredicate *)predict clazz:(Class)cls orderBy:(NSString *)sorter,... {
    NSArray *array = [self getObjects:predict clazz:cls];
    
    if (sorter && array) {
        va_list list;
        va_start(list, sorter);
        
        NSMutableArray *sorters = [[NSMutableArray alloc] init];
        NSString *tSorter;
        while ( (tSorter = va_arg(list, NSString *)) ) {
            NSArray *comps = [tSorter componentsSeparatedByString:@" "];
            if (comps) {
                if (comps.count == 2) {
                    NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
                                                initWithKey:[comps objectAtIndex:0]
                                                ascending:[[comps objectAtIndex:1] compare:@"asc"
                                                                                   options:NSCaseInsensitiveSearch]];
                    [sorters addObject:sorter];
                    [sorter release];
                } else if (comps.count == 1) {
                    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:tSorter ascending:YES];
                    [sorters addObject:sorter];
                    [sorter release];
                }
            }
        }
        
        va_end(list);
        array = [array sortedArrayUsingDescriptors:sorters];
        [sorters release];
    }

    if ([array count]) {
        return [array objectAtIndex:0];
    }
    return nil;
}

- (NSArray *)getObjects:(NSPredicate *)predict clazz:(Class)cls {
    return [[self getContainer:NSStringFromClass(cls)]
            filteredArrayUsingPredicate:predict];
}

- (NSArray *)getObjects:(NSPredicate *)predict clazz:(Class)cls orderBy:(NSString *)sorter,... NS_REQUIRES_NIL_TERMINATION{
    NSArray *array = [self getObjects:predict clazz:cls];
    
    if (sorter && array) {
        NSMutableArray *sorters = [[NSMutableArray alloc] init];
        
        va_list args;
        va_start(args, sorter);
        for (NSString *arg = sorter; arg != nil; arg = va_arg(args, NSString*)) {
            NSArray *comps = [arg componentsSeparatedByString:@" "];
            if (comps) {
                if (comps.count == 2) {
                    bool asc = ([[comps objectAtIndex:1] compare:@"asc" options:NSCaseInsensitiveSearch] != NSOrderedDescending);
                    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:[comps objectAtIndex:0] ascending:asc];
                    [sorters addObject:sorter];
                    [sorter release];
                } else if (comps.count == 1) {
                    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:arg ascending:YES];
                    [sorters addObject:sorter];
                    [sorter release];
                }
            }

        }
        va_end(args);
        
        NSArray *ret = [array sortedArrayUsingDescriptors:sorters];
        [sorters release];

        return ret;
    }
    
    return array;
}

- (ConcurrentMutableArray *)getContainer:(NSString *)name {
    __block ConcurrentMutableArray *array = nil;
    if ([self.holder valueForKey:name]) {
        array = [self.holder valueForKey:name];
    } else {
        @synchronized([MemContainer class]) {
            if (![self.holder valueForKey:name]) {
                array = [[ConcurrentMutableArray alloc] init];
                [self.holder setValue:array forKey:name];
                [array release];
            }
        }
    }
    return array;
}

@end
