//
//  SimpleSegment.m
//  baby
//
//  Created by zhang da on 14-3-17.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "SimpleSegment.h"

#define BASIC_TAG 88888

@implementation SimpleSegment

- (void)dealloc {
    [buttons release];
    buttons = nil;
    
    self.selectedBackgoundColor = nil;
    self.normalBackgroundColor = nil;
    self.selectedTextColor = nil;
    self.normalTextColor = nil;
    self.borderColor = nil;
    
    self.delegate = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame titles:(NSArray *)titles borderWidth:(int)width {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.masksToBounds = YES;
        NSInteger count = titles.count;
        buttons = [[NSMutableArray alloc] init];
        _selectedIndex = 0;
        _borderWidth = width;

        holder = [[UIView alloc] initWithFrame:CGRectMake(width, width, frame.size.width - width*2, frame.size.height - 2*width)];
        holder.layer.masksToBounds = YES;
        holder.layer.cornerRadius = 13;
        holder.layer.borderWidth = 1;
        holder.backgroundColor = [UIColor yellowColor];
        [self addSubview:holder];
        [holder release];
        
        float btnWidth = (holder.frame.size.width*1.0)/count;
        for (int i = 0; i < count; i ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.layer.masksToBounds = YES;
            btn.frame = CGRectMake(btnWidth*i, 0, btnWidth, frame.size.height - 2*width);
            btn.tag = BASIC_TAG + i;
            
            [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [btn setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:MIN(14, frame.size.height - 4)];
            
            [btn addTarget:self action:@selector(segmentSelected:) forControlEvents:UIControlEventTouchUpInside];
            [holder addSubview:btn];
            [buttons addObject:btn];
        }
        
        [self updateLayout];
    }
    return self;
}

- (void)setBorderColor:(UIColor *)borderColor {
    holder.layer.borderColor = borderColor.CGColor;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (_selectedIndex != selectedIndex) {
        _selectedIndex = selectedIndex;
        
        for (NSInteger i = 0; i < buttons.count; i ++) {
            UIButton *btn = [buttons objectAtIndex:i];
            if (i == selectedIndex) {
                //highlighted
                btn.backgroundColor = self.selectedBackgoundColor;
                [btn setTitleColor:self.selectedTextColor forState:UIControlStateNormal];
            } else {
                btn.backgroundColor = self.normalBackgroundColor;
                [btn setTitleColor:self.normalTextColor forState:UIControlStateNormal];
            }
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(segmentSelected:)]) {
            [self.delegate segmentSelected:selectedIndex];
        }
    }
}

- (void)updateLayout {
    //for (UIButton *btn in buttons) {
        //btn.layer.borderColor = self.borderColor.CGColor;
        //btn.layer.borderWidth = 1;
    //}
    for (int i = 0; i < buttons.count; i ++) {
        UIButton *btn = [buttons objectAtIndex:i];
        if (i == _selectedIndex) {
            //highlighted
            btn.backgroundColor = self.selectedBackgoundColor;
            [btn setTitleColor:self.selectedTextColor forState:UIControlStateNormal];
        } else {
            btn.backgroundColor = self.normalBackgroundColor;
            [btn setTitleColor:self.normalTextColor forState:UIControlStateNormal];
        }
    }

}

- (UIButton *)segmentAtIndex:(NSInteger)index {
    if ([buttons count] > index) {
        return [buttons objectAtIndex:index];
    }
    return nil;
}

- (void)segmentSelected:(UIButton *)btn {
    NSInteger index = btn.tag - BASIC_TAG;
    self.selectedIndex = index;
}

@end
