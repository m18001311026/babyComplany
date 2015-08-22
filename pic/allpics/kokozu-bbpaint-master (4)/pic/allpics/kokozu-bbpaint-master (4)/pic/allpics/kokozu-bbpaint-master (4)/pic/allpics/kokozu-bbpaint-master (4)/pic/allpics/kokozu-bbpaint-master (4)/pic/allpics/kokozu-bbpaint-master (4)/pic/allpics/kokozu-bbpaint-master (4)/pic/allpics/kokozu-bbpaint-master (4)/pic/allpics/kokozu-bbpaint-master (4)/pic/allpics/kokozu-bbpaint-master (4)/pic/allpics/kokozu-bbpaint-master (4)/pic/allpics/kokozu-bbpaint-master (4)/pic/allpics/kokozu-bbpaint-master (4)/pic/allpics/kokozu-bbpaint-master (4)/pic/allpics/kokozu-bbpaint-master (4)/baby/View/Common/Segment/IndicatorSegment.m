//
//  IndicatorSegment.m
//  baby
//
//  Created by zhang da on 14-3-17.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "IndicatorSegment.h"

#define BASIC_TAG 88888

@implementation IndicatorSegment

- (void)dealloc {
    [buttons release];
    buttons = nil;
    
    [indicators release];
    indicators = nil;
    
    self.selectedColor = nil;
    self.normalColor = nil;
    self.textColor = nil;
    
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

- (id)initWithFrame:(CGRect)frame titles:(NSArray *)titles {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        NSInteger count = titles.count;
        buttons = [[NSMutableArray alloc] init];
        indicators = [[NSMutableArray alloc] init];
        
        _selectedIndex = 0;

        float btnWidth = (frame.size.width*1.0)/count;
        for (int i = 0; i < count; i ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(btnWidth*i, 0, btnWidth, frame.size.height);
            btn.tag = BASIC_TAG + i;
            btn.titleLabel.textAlignment = UITextAlignmentCenter;
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:MIN(14, frame.size.height - 4)];
            
            [btn addTarget:self action:@selector(segmentSelected:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            [buttons addObject:btn];
            
            UIView *indicator = [[UIView alloc] initWithFrame:
                                 CGRectMake(btnWidth*i, frame.size.height - 3, btnWidth, 1)];
            indicator.backgroundColor = self.normalColor;
            [self addSubview:indicator];
            [indicators addObject:indicator];
            [indicator release];
        }
        
        [self updateLayout];
    }
    return self;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (_selectedIndex != selectedIndex) {
        _selectedIndex = selectedIndex;
        
        for (NSInteger i = 0; i < buttons.count; i ++) {
            UIView *indicator = [indicators objectAtIndex:i];
            float btnWidth = (self.frame.size.width*1.0)/buttons.count;
            if (i == selectedIndex) {
                //highlighted
                indicator.frame = CGRectMake(btnWidth*i, self.frame.size.height - 5, btnWidth, 5);
                indicator.backgroundColor = self.selectedColor;
            } else {
                indicator.frame = CGRectMake(btnWidth*i, self.frame.size.height - 3, btnWidth, 1);
                indicator.backgroundColor = self.normalColor;
            }
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(segmentSelected:)]) {
            [self.delegate segmentSelected:selectedIndex];
        }
    }
}

- (void)updateLayout {
    for (int i = 0; i < buttons.count; i ++) {
        UIButton *btn = [buttons objectAtIndex:i];
        [btn setTitleColor:self.textColor forState:UIControlStateNormal];
        UIView *indicator = [indicators objectAtIndex:i];
        float btnWidth = (self.frame.size.width*1.0)/buttons.count;

        if (i == _selectedIndex) {
            indicator.frame = CGRectMake(btnWidth*i, self.frame.size.height - 5, btnWidth, 5);
            indicator.backgroundColor = self.selectedColor;
        } else {
            indicator.frame = CGRectMake(btnWidth*i, self.frame.size.height - 3, btnWidth, 1);
            indicator.backgroundColor = self.normalColor;
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
