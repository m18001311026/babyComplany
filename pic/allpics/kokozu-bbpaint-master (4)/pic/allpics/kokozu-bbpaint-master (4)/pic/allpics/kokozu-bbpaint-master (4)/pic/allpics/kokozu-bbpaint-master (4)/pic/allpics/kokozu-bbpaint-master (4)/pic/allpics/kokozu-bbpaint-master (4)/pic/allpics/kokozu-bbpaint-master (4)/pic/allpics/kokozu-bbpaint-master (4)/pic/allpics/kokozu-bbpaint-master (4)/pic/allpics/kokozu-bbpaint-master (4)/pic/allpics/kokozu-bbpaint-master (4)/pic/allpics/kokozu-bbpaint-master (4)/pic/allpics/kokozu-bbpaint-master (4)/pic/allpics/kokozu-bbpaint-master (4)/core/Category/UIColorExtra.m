//
//  UIColorExtra.m
//  phonebook
//
//  Created by kokozu on 10-12-18.
//  Copyright 2010 公司. All rights reserved.
//

#import "UIColorExtra.h"


@implementation UIColor (UIColorExtra)

+ (UIColor *)r:(int)red g:(int)green b:(int)blue alpha:(float)alpha {
    return [UIColor colorWithRed:red/255.0
                           green:green/255.0
                            blue:blue/255.0
                           alpha:alpha];
}

+ (UIColor *)r:(int)red g:(int)green b:(int)blue {
    return [UIColor colorWithRed:red/255.0
                           green:green/255.0
                            blue:blue/255.0
                           alpha:1];
}

+ (UIColor *)randColor {
    return [UIColor r:rand()%255 g:rand()%255 b:rand()%255];
}

- (UIColor *)alpha:(float)a {
    return [self colorWithAlphaComponent:a];
}

@end
