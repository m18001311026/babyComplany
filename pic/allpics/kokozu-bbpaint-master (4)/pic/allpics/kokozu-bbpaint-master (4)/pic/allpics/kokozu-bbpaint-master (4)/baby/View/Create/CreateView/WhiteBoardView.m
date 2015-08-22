//
//  WhiteBoardView.m
//  baby
//
//  Created by zhang da on 15/6/30.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import "WhiteBoardView.h"
#import "ImageView.h"
#import "BackgroundTextView.h"

#define INDEX_BASE 1000
#define INIT_WIDTH 150

@interface WhiteBoardView() {
    bool _editing;
    CGPoint _panPoint;
    CGFloat _lastRotation;

    UIView *contentView;
    ImageView *backgroundImage;
}
@end

@implementation WhiteBoardView


- (void)dealloc {
    [stickers release]; stickers = nil;
    
    [super dealloc];
}

- (void)setCurrentSticker:(ZDStickerView *)currentSticker {
    if (_currentSticker != currentSticker) {
//        _currentSticker.layer.borderColor = [UIColor clearColor].CGColor;
//        _currentSticker.layer.borderWidth = 0;
        [_currentSticker showFrame:NO];
        [_currentSticker hideEditingHandles];

        _currentSticker = currentSticker;
        
//        _currentSticker.layer.borderColor = [UIColor orangeColor].CGColor;
//        _currentSticker.layer.borderWidth = 1;
        [_currentSticker showFrame:YES];
        [_currentSticker showEditingHandles];
    }
}

- (id)initWithFrame:(CGRect)frame background:(UIImage *)image {
    self = [super initWithFrame:frame];
    if (self) {
        _editing = NO;
        
        stickers = [[NSMutableArray alloc] init];
        
        backgroundImage = [[ImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        
        backgroundImage.backgroundColor = [UIColor whiteColor];
        backgroundImage.image = image;
        [self addSubview:backgroundImage];
        [backgroundImage release];
        
        contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        contentView.backgroundColor = [UIColor clearColor];
        contentView.clipsToBounds = YES;
        [self addSubview:contentView];
        [contentView release];
        
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(handlePinch:)];
        pinch.cancelsTouchesInView = NO;
        [self addGestureRecognizer:pinch];
        [pinch release];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(handlePan:)];
        pan.cancelsTouchesInView = NO;
        [self addGestureRecognizer:pan];
        [pan release];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(handleTap:)];
        singleTap.cancelsTouchesInView = NO;
        [self addGestureRecognizer:singleTap];
        [singleTap release];
        
        UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc]
                                                initWithTarget:self
                                                action:@selector(handleRotate:)];
        rotation.cancelsTouchesInView = NO;
        [self addGestureRecognizer:rotation];
        [rotation release];

    }
    return self;
}

- (UIImage *)layoutImage {
    self.currentSticker = nil;
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0f);
    //ios 7 available
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    //[self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (bool)hasView {
    return [contentView subviews].count;
}

- (void)hideControl {
    self.currentSticker = nil;
}


#pragma sticker view delegate
- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self];
    NSArray *subviews = [contentView subviews];
    for (UIView *view in subviews) {
        if (CGRectContainsPoint(view.frame, point)) {
            return;
        }
    }
    self.currentSticker = nil;
}

- (void)handleRotate:(UIRotationGestureRecognizer *)recognizer {
    if([recognizer state] == UIGestureRecognizerStateEnded) {
        _lastRotation = 0.0;
        return;
    }
    
    CGFloat rotation = 0.0 - (_lastRotation - [recognizer rotation]);
    
    CGAffineTransform currentTransform = self.currentSticker.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, rotation);
    
    [self.currentSticker setTransform:newTransform];
    
    _lastRotation = [recognizer rotation];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    if (self.currentSticker) {
        float scale = recognizer.scale;
        
        float width = self.currentSticker.bounds.size.width*scale;
        float height = self.currentSticker.bounds.size.height*scale;
        
        if (width > 800 || height > 800) {
            scale = 300/MAX(self.currentSticker.bounds.size.width, self.currentSticker.bounds.size.height);
        }
        if (width < 50 || height < 50) {
            scale = 50/MIN(self.currentSticker.bounds.size.width, self.currentSticker.bounds.size.height);
        }
        
        self.currentSticker.bounds = CGRectMake(
                                                self.currentSticker.bounds.origin.x,
                                                self.currentSticker.bounds.origin.y,
                                                self.currentSticker.bounds.size.width*scale,
                                                self.currentSticker.bounds.size.height*scale);
        [self.currentSticker layoutControlSet];
    }
    
    recognizer.scale = 1;
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self];
    NSArray *subviews = [contentView subviews];
    for (UIView *view in subviews) {
        if (CGRectContainsPoint(view.frame, point)) {
            return;
        }
    }
    if (self.currentSticker) {
        if ([recognizer state]== UIGestureRecognizerStateBegan) {
            _panPoint = [recognizer locationInView:self];
        } else if ([recognizer state] == UIGestureRecognizerStateChanged) {
            CGPoint touchPoint = [recognizer locationInView:self];
            
            CGPoint newCenter = CGPointMake(self.currentSticker.center.x + touchPoint.x - _panPoint.x,
                                            self.currentSticker.center.y + touchPoint.y - _panPoint.y);
            
            // Ensure the translation won't cause the view to move offscreen.
//            CGFloat midPointX = CGRectGetMidX(self.currentSticker.bounds);
//            if (newCenter.x > self.bounds.size.width - midPointX) {
//                newCenter.x = self.bounds.size.width - midPointX;
//            }
//            if (newCenter.x < midPointX) {
//                newCenter.x = midPointX;
//            }
//            CGFloat midPointY = CGRectGetMidY(self.currentSticker.bounds);
//            if (newCenter.y > self.bounds.size.height - midPointY) {
//                newCenter.y = self.bounds.size.height - midPointY;
//            }
//            if (newCenter.y < midPointY) {
//                newCenter.y = midPointY;
//            }
            
            self.currentSticker.center = newCenter;
            _panPoint = touchPoint;
        } else if ([recognizer state] == UIGestureRecognizerStateEnded) {
            _panPoint = [recognizer locationInView:self];
        }
    }
}

- (void)stickerViewDidBeginEditing:(ZDStickerView *)sticker {
    //NSLog(@"index: %ld", sticker.tag - INDEX_BASE);
    self.currentSticker = sticker;
}

- (void)stickerViewDidEndEditing:(ZDStickerView *)sticker {

}

- (void)stickerViewDidCancelEditing:(ZDStickerView *)sticker {

}

- (void)stickerViewDidClose:(ZDStickerView *)sticker {

}

- (void)stickerViewDidShowMore:(ZDStickerView *)sticker {
    if (self.delegate && [self.delegate respondsToSelector:@selector(stickerMoreTouched:)]) {
        [self.delegate stickerMoreTouched:sticker.contentView];
    }
}

- (void)stickerViewDidDoubleTap:(ZDStickerView *)sticker {
    if (self.delegate && [self.delegate respondsToSelector:@selector(stickerMoreTouched:)]) {
        [self.delegate stickerMoreTouched:sticker.contentView];
    }
}


#pragma mark control
- (void)addView:(UIView *)view {
    if (view) {
        CGRect frame = [ZDStickerView initFrame:view.frame];
        
        ZDStickerView *sticker = [[ZDStickerView alloc] initWithFrame:frame];
        sticker.center = contentView.center;
        sticker.delegate = self;
        sticker.contentView = view;
        sticker.preventsPositionOutsideSuperview = YES;
        [sticker showEditingHandles];
        [contentView insertSubview:sticker atIndex:stickers.count];
        sticker.tag = INDEX_BASE + stickers.count;
        [sticker release];

        [stickers addObject:sticker];
        
        self.currentSticker = sticker;
    }
}

- (void)upSticker {
    if (_editing) {
        return;
    } else {
        _editing = YES;
    }
    
    NSInteger currentIndex = self.currentSticker.tag - INDEX_BASE;
    if (currentIndex < stickers.count - 1) {
        ZDStickerView *toDown = (ZDStickerView *)[contentView viewWithTag:currentIndex + INDEX_BASE + 1];
        ZDStickerView *now = (ZDStickerView *)[contentView viewWithTag:currentIndex + INDEX_BASE];

        [contentView exchangeSubviewAtIndex:currentIndex + 1
                         withSubviewAtIndex:currentIndex];
        
        toDown.tag = currentIndex + INDEX_BASE;
        now.tag = currentIndex + INDEX_BASE + 1;
    } else {
        
    }
    
    _editing = NO;
}

- (void)downSticker {
    if (_editing) {
        return;
    } else {
        _editing = YES;
    }
    
    NSInteger currentIndex = self.currentSticker.tag - INDEX_BASE;
    if (currentIndex > 0) {
        ZDStickerView *now = (ZDStickerView *)[contentView viewWithTag:currentIndex + INDEX_BASE];
        ZDStickerView *toUp = (ZDStickerView *)[contentView viewWithTag:currentIndex + INDEX_BASE - 1];
        
        [contentView exchangeSubviewAtIndex:currentIndex
                         withSubviewAtIndex:currentIndex - 1];
        
        now.tag = currentIndex + INDEX_BASE -1;
        toUp.tag = currentIndex + INDEX_BASE;
    }
    
    _editing = NO;
}

@end
