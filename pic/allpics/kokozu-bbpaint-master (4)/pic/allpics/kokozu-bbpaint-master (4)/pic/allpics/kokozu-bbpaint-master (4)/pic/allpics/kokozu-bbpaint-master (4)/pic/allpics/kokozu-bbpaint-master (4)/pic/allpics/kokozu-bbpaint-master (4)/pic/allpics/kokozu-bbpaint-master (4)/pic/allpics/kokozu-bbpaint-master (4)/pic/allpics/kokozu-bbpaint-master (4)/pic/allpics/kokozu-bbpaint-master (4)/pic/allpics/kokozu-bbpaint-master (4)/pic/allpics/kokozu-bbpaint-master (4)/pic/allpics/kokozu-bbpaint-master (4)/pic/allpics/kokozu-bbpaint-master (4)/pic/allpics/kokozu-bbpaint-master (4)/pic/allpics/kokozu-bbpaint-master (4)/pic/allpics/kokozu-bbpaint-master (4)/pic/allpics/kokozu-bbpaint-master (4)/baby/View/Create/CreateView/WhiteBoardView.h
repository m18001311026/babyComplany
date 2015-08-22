//
//  WhiteBoardView.h
//  baby
//
//  Created by zhang da on 15/6/30.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZDStickerView.h"

@protocol WhiteBoardViewDelegate <NSObject>

- (void)stickerMoreTouched:(UIView *)contentView;

@end


@interface WhiteBoardView : UIView <ZDStickerViewDelegate> {
    
    NSMutableArray *stickers;
    
}

@property (nonatomic, assign) id<WhiteBoardViewDelegate> delegate;
@property (nonatomic, assign) ZDStickerView *currentSticker;

- (void)upSticker;
- (void)downSticker;

- (void)addView:(UIView *)view;
- (bool)hasView;

- (UIImage *)layoutImage;
- (void)hideControl;

- (id)initWithFrame:(CGRect)frame background:(UIImage *)image;

@end
