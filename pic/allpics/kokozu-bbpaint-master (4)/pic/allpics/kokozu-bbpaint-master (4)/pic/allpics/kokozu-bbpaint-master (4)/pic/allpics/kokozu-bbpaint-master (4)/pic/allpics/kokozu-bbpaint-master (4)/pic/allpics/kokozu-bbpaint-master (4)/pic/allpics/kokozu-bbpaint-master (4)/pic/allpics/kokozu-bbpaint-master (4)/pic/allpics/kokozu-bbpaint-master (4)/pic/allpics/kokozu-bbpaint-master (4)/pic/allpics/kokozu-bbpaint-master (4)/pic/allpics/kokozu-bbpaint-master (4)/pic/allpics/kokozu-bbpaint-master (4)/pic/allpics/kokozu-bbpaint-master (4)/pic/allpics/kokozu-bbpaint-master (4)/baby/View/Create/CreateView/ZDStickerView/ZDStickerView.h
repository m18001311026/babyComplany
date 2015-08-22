//
//  ZDStickerView.h
//
//  Created by Seonghyun Kim on 5/29/13.
//  Copyright (c) 2013 scipi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZDStickerViewDelegate;

@interface ZDStickerView : UIView {
    NSMutableDictionary *_controlSet;
    UIView *_frame;
}

@property (nonatomic, assign) UIView *contentView;
@property (nonatomic, assign) BOOL preventsPositionOutsideSuperview; //default = YES
@property (nonatomic, assign) BOOL preventsResizing; //default = NO
@property (nonatomic, assign) BOOL preventsDeleting; //default = NO
@property (nonatomic, assign) BOOL preventsLayoutWhileResizing;
@property (nonatomic, assign) CGFloat minWidth;
@property (nonatomic, assign) CGFloat minHeight;

@property (nonatomic, assign) CGPoint prevPoint;
@property (nonatomic, assign) float prevScale;
@property (nonatomic, assign) float deltaAngle;
@property (nonatomic, assign) BOOL verficalFlipped;
@property (nonatomic, assign) BOOL horizonFlipped;

@property (nonatomic, assign) id <ZDStickerViewDelegate> delegate;

+ (CGRect)initFrame:(CGRect)currentFrame;
- (void)hideEditingHandles;
- (void)showEditingHandles;
- (void)layoutControlSet;
- (void)showFrame:(bool)show;

@end


@protocol ZDStickerViewDelegate <NSObject>
@required
@optional
- (void)stickerViewDidBeginEditing:(ZDStickerView *)sticker;
- (void)stickerViewDidEndEditing:(ZDStickerView *)sticker;
- (void)stickerViewDidCancelEditing:(ZDStickerView *)sticker;
- (void)stickerViewDidClose:(ZDStickerView *)sticker;
- (void)stickerViewDidShowMore:(ZDStickerView *)sticker;
- (void)stickerViewDidDoubleTap:(ZDStickerView *)sticker;
@end


