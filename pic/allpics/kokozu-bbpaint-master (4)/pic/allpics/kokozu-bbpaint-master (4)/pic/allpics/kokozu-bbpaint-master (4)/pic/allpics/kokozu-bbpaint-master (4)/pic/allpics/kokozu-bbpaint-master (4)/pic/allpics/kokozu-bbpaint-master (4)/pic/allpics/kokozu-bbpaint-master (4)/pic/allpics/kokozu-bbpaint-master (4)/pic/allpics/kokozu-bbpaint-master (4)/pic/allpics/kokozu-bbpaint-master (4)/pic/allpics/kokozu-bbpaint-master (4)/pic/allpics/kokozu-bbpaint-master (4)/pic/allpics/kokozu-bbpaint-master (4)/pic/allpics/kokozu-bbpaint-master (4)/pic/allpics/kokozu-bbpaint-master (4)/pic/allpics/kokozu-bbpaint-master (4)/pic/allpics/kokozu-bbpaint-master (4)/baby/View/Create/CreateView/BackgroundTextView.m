//
//  BackgroundTextView.m
//  baby
//
//  Created by zhang da on 15/7/15.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import "BackgroundTextView.h"

#define INSET_TOP 5
#define INSET_LEFT 22
#define INSET_BOTTOM 10
#define INSET_RIGTH 5

@implementation BackgroundTextView

- (void)dealloc {
    
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        bg = [[UIImageView alloc] init];
        bg.image = [UIImage imageNamed:@"Speech-Bubble.png"];
        [self addSubview:bg];
        //[self sendSubviewToBack:bg];
        [bg release];
        
         _textView = [[UITextView alloc] init];
        [self addSubview:_textView];
        [_textView release];
        
//        self.textView.backgroundColor = [UIColor colorWithWhite:.2 alpha:.1];
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.clipsToBounds = YES;
        if (iOS5 || iOS6) {
            self.textView.contentInset = UIEdgeInsetsMake(INSET_TOP, INSET_LEFT, INSET_BOTTOM, INSET_RIGTH);
        } else {
            [self.textView setTextContainerInset:UIEdgeInsetsMake(INSET_TOP, INSET_LEFT, INSET_BOTTOM, INSET_RIGTH)];
        }

        [self.textView addObserver:self
                        forKeyPath:@"contentSize"
                           options:(NSKeyValueObservingOptionNew)
                           context:NULL];

    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *txtview = object;
    CGFloat topoffset = ([txtview bounds].size.height - [txtview contentSize].height * [txtview zoomScale])/2.0;
    topoffset = ( topoffset < 0.0 ? 0.0 : topoffset );
    txtview.contentOffset = (CGPoint){.x = 0, .y = -topoffset};
}

- (void)setFrame:(CGRect)newFrame {
    int width = newFrame.size.width;
    if (width > 150) {
        if (iOS5 || iOS6) {
            self.textView.contentInset = UIEdgeInsetsMake(INSET_TOP, INSET_LEFT + 5, INSET_BOTTOM, INSET_RIGTH + 5);
        } else {
            [self.textView setTextContainerInset:UIEdgeInsetsMake(INSET_TOP, INSET_LEFT + 5, INSET_BOTTOM, INSET_RIGTH + 5)];
        }
    } else {
        if (iOS5 || iOS6) {
            self.textView.contentInset = UIEdgeInsetsMake(INSET_TOP, INSET_LEFT, INSET_BOTTOM, INSET_RIGTH);
        } else {
            [self.textView setTextContainerInset:UIEdgeInsetsMake(INSET_TOP, INSET_LEFT, INSET_BOTTOM, INSET_RIGTH)];
        }
    }
    
    [super setFrame:newFrame];
    bg.frame = CGRectInset(self.bounds, 0, 0);
    self.textView.frame = CGRectInset(self.bounds, 0, 0);
}

@end
