//
//  ShareView.m
//  baby
//
//  Created by zhang da on 14-5-9.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "ShareView.h"


@interface ShareBtn : UIControl {
    UIImageView *iconView;
}

@property (nonatomic, retain) UIImage *normalImage;
@property (nonatomic, retain) UIImage *highlightedImage;

@end


@implementation ShareBtn

- (void)dealloc {
    self.normalImage = nil;
    self.highlightedImage = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame normal:(UIImage *)nImage highlighted:(UIImage *)hImage {
    self = [super initWithFrame:frame];
    if (self) {
        self.normalImage = nImage;
        self.highlightedImage = hImage;
        
        iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        iconView.backgroundColor = [UIColor clearColor];
        iconView.image = self.normalImage;
        [self addSubview:iconView];
        [iconView release];
        
        [self addTarget:self
                 action:@selector(touched)
       forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)touched {
    self.selected = !self.selected;
    iconView.image = self.selected? self.highlightedImage: self.normalImage;
}

@end


@implementation ShareView

- (void)dealloc {
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        info = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 50, 20)];
        info.backgroundColor = [UIColor clearColor];
        info.font = [UIFont systemFontOfSize:14];
        info.textColor = [UIColor lightGrayColor];
        info.text = @"同步到";
        [self addSubview:info];
        [info release];
        
        weixin = [[ShareBtn alloc] initWithFrame:CGRectMake(70, 7, 30, 30)
                                          normal:[UIImage imageNamed:@"share_weixin_n"]
                                     highlighted:[UIImage imageNamed:@"share_weixin_h"]];
        [self addSubview:weixin];
        [weixin release];
        
        weibo = [[ShareBtn alloc] initWithFrame:CGRectMake(115, 7, 30, 30)
                                          normal:[UIImage imageNamed:@"share_sina_n"]
                                     highlighted:[UIImage imageNamed:@"share_sina_h"]];
        [self addSubview:weibo];
        [weibo release];
        
        qweibo = [[ShareBtn alloc] initWithFrame:CGRectMake(160, 7, 30, 30)
                                         normal:[UIImage imageNamed:@"share_qbo_n"]
                                    highlighted:[UIImage imageNamed:@"share_qbo_h"]];
        [self addSubview:qweibo];
        [qweibo release];
        
        qzone = [[ShareBtn alloc] initWithFrame:CGRectMake(205, 7, 30, 30)
                                          normal:[UIImage imageNamed:@"share_qzone_n"]
                                     highlighted:[UIImage imageNamed:@"share_qzone_h"]];
        [self addSubview:qzone];
        [qzone release];
        
    }
    return self;
}

- (bool)enableWeixin { return weixin.selected; }

- (bool)enableWeibo { return weibo.selected; }

- (bool)enableQweibo { return qweibo.selected; }

- (bool)enableQzone { return qzone.selected; }


@end
