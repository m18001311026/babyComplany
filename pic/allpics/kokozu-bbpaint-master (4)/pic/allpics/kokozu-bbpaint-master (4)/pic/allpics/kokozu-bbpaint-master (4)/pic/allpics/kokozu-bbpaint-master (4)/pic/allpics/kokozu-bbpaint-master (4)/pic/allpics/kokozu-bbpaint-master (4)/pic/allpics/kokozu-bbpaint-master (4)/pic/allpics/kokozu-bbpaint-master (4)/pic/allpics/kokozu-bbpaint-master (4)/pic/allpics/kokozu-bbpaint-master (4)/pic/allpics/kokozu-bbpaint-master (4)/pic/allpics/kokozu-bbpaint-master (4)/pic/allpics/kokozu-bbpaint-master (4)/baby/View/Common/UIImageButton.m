//
//  UIImageButton.m
//  baby
//
//  Created by zhang da on 14-3-6.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "UIImageButton.h"

@interface UIImageButton()

@end

@implementation UIImageButton

- (void)dealloc {
    self.icon = nil;
    self.text = nil;
    
    self.textNormalColor = nil;
    self.textHighlightedColor = nil;
    self.textSelectedColor = nil;
    
    [super dealloc];
}

- (void)setTextNormalColor:(UIColor *)textNormalColor {
    if (_textNormalColor != textNormalColor) {
        [_textNormalColor release];
        _textNormalColor = [textNormalColor retain];
        
        self.text.textColor = textNormalColor;
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.icon = icon;
        [self addSubview:self.icon];
        [icon release];
        
        UILabel *text = [[UILabel alloc] initWithFrame:CGRectZero];
        self.text = text;
        [self addSubview:text];
        [text release];

    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self centerContent];
}

- (id)initWithFrame:(CGRect)frame
              image:(NSString *)imageName
        imageHeight:(int)imageHeight
               text:(NSString *)text
           fontSize:(int)fontSize {
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectZero];
        icon.contentMode = UIViewContentModeScaleAspectFit;
        self.icon = icon;
        [icon release];

        self.icon.image = [UIImage imageNamed:imageName];
        [self addSubview:self.icon];
        self.imageHeight = imageHeight;
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.backgroundColor = [UIColor clearColor];
        self.text = textLabel;
        [textLabel release];

        self.text.font = [UIFont systemFontOfSize:fontSize];
        self.text.text = text;
        self.text.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.text];
        
        [self centerContent];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    self.icon.image = image;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)centerContent {
    int margin = 4;
    CGSize textSize = [self.text.text sizeWithFont:self.text.font];
    CGSize imageSize = CGSizeMake(self.imageHeight, self.imageHeight);
    
    int originX = (self.frame.size.width - textSize.width - imageSize.width - margin)/2;
    
    if (self.icon.image) {
        self.icon.frame = CGRectMake(originX,
                                     (self.frame.size.height - self.imageHeight)/2,
                                     self.imageHeight,
                                     self.imageHeight);
        self.text.frame = CGRectMake(originX + self.imageHeight + margin,
                                     (self.frame.size.height - textSize.height)/2,
                                     textSize.width,
                                     textSize.height);
    } else {
        self.icon.frame = CGRectZero;
        self.text.frame = CGRectMake(originX,
                                     (self.frame.size.height - textSize.height)/2,
                                     self.frame.size.width - originX*2,
                                     textSize.height);
    }
}

@end
