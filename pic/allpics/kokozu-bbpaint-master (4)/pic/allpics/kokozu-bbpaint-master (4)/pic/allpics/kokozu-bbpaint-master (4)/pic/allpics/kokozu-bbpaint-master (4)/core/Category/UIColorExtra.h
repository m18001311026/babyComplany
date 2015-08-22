//
//  UIColorExtra.h
//  phonebook
//
//  Created by kokozu on 10-12-18.
//  Copyright 2010 公司. All rights reserved.
//

@interface UIColor (UIColorExtra) 

+ (UIColor *)r:(int)red g:(int)green b:(int)blue alpha:(float)alpha;
+ (UIColor *)r:(int)red g:(int)green b:(int)blue;
+ (UIColor *)randColor;
- (UIColor *)alpha:(float)alpha;

@end
