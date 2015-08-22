//
//  ZDStickerView.m
//
//  Created by Seonghyun Kim on 5/29/13.
//  Copyright (c) 2013 scipi. All rights reserved.
//

#import "ZDStickerView.h"
#import <QuartzCore/QuartzCore.h>

#define kSPUserResizableViewGlobalInset 5.0
#define kSPUserResizableViewDefaultMinWidth 50
#define kSPUserResizableViewInteractiveBorderSize 10.0
#define STICKER_CTR_SIZE 25.0

#define UP_LEFT CGRectMake(0, 0, STICKER_CTR_SIZE, STICKER_CTR_SIZE)
#define UP_RIGHT CGRectMake(self.bounds.size.width-STICKER_CTR_SIZE, 0, STICKER_CTR_SIZE, STICKER_CTR_SIZE)
#define DOWN_LEFT CGRectMake(0, self.bounds.size.height-STICKER_CTR_SIZE, STICKER_CTR_SIZE, STICKER_CTR_SIZE)
#define DOWN_RIGHT CGRectMake(self.bounds.size.width-STICKER_CTR_SIZE, self.bounds.size.height-STICKER_CTR_SIZE, STICKER_CTR_SIZE, STICKER_CTR_SIZE)

#define FRAME_FRAME CGRectMake(STICKER_CTR_SIZE/2, STICKER_CTR_SIZE/2, self.bounds.size.width-STICKER_CTR_SIZE, self.bounds.size.height-STICKER_CTR_SIZE)
#define CONTENT_FRAME CGRectInset(self.bounds, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2)

#define POS_UP_LEFT @"sticker.up.left"
#define POS_UP_RIGHT @"sticker.up.right"
#define POS_DOWN_LEFT @"sticker.down.left"
#define POS_DOWN_RIGHT @"sticker.down.right"


typedef enum {
    MORE,
    DELETE,
    RESIZE,
    HORIZON_FLIP,
    VERTICAL_FLIP
} ControlType;

@interface ZDStickerView(Control) {
    
}

+ (UIView *)getControl:(ControlType)type forSticker:(ZDStickerView *)sticker;

- (void)addControl:(UIView *)ctr atPos:(NSString *)pos;
- (void)layoutControlSet;
- (void)hideAll;
- (void)showAll;

@end

@implementation ZDStickerView(Control)

//static method
- (void)addControl:(UIView *)control atPos:(NSString *)pos {
    if (!_controlSet) {
        _controlSet = [[NSMutableDictionary alloc] init];
    }
    if ([pos isEqualToString:POS_UP_LEFT]) {
        control.frame = UP_LEFT;
    } else if ([pos isEqualToString:POS_UP_RIGHT]) {
        control.frame = UP_RIGHT;
    } else if ([pos isEqualToString:POS_DOWN_LEFT]) {
        control.frame = DOWN_LEFT;
    } else if ([pos isEqualToString:POS_DOWN_RIGHT]) {
        control.frame = DOWN_RIGHT;
    }
    [_controlSet setObject:control forKey:pos];
    [self addSubview:control];
}

- (void)layoutControlSet {
    NSArray *poss = [_controlSet allKeys];
    for (NSString *pos in poss) {
        if ([pos isEqualToString:POS_UP_LEFT]) {
            UIView *ctr = [_controlSet objectForKey:pos];
            ctr.frame = UP_LEFT;
        } else if ([pos isEqualToString:POS_UP_RIGHT]) {
            UIView *ctr = [_controlSet objectForKey:pos];
            ctr.frame = UP_RIGHT;
        } else if ([pos isEqualToString:POS_DOWN_LEFT]) {
            UIView *ctr = [_controlSet objectForKey:pos];
            ctr.frame = DOWN_LEFT;
        } else if ([pos isEqualToString:POS_DOWN_RIGHT]) {
            UIView *ctr = [_controlSet objectForKey:pos];
            ctr.frame = DOWN_RIGHT;
        }
    }
    _frame.frame = FRAME_FRAME;
}

- (void)bringControlToFront {
    NSArray *poss = [_controlSet allKeys];
    for (NSString *pos in poss) {
        UIView *control = [_controlSet objectForKey:pos];
        [self bringSubviewToFront:control];
    }
}

+ (UIView *)getControl:(ControlType)type forSticker:(ZDStickerView *)sticker {
    if (type == DELETE) {
        UIImageView *deleteControl = [[UIImageView alloc] initWithFrame:CGRectZero];
        deleteControl.backgroundColor = [UIColor clearColor];
        deleteControl.image = [UIImage imageNamed:@"ZDBtn_delete.png" ];
        deleteControl.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                             initWithTarget:sticker
                                             action:@selector(deleteTap:)];
        [deleteControl addGestureRecognizer:singleTap];
        [singleTap release];
        
        return [deleteControl autorelease];
    } else if (type == RESIZE) {
        UIImageView *resizingControl = [[UIImageView alloc] initWithFrame:CGRectZero];
        resizingControl.backgroundColor = [UIColor clearColor];
        resizingControl.userInteractionEnabled = YES;
        resizingControl.image = [UIImage imageNamed:@"ZDBtn_resize.png"];
        
        UIPanGestureRecognizer *panResizeGesture = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:sticker
                                                    action:@selector(resizeMoved:)];
        [resizingControl addGestureRecognizer:panResizeGesture];
        [panResizeGesture release];
        
        return [resizingControl autorelease];
    } else if (type == MORE) {
        UIImageView *moreControl = [[UIImageView alloc] initWithFrame:CGRectZero];
        moreControl.backgroundColor = [UIColor clearColor];
        moreControl.userInteractionEnabled = YES;
        moreControl.image = [UIImage imageNamed:@"ZDBtn_more.png" ];
        
        UITapGestureRecognizer *singleTapMore = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:sticker
                                                 action:@selector(moreTap:)];
        [moreControl addGestureRecognizer:singleTapMore];
        [singleTapMore release];
        
        return [moreControl autorelease];
    } else if (type == HORIZON_FLIP) {
        UIImageView *control = [[UIImageView alloc] initWithFrame:CGRectZero];
        control.backgroundColor = [UIColor redColor];
        control.userInteractionEnabled = YES;
        control.image = [UIImage imageNamed:@"ZDBtn_more.png" ];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                             initWithTarget:sticker
                                             action:@selector(flipHorizon:)];
        [control addGestureRecognizer:singleTap];
        [singleTap release];
        
        return [control autorelease];
    } else if (type == VERTICAL_FLIP) {
        UIImageView *control = [[UIImageView alloc] initWithFrame:CGRectZero];
        control.backgroundColor = [UIColor greenColor];
        control.userInteractionEnabled = YES;
        control.image = [UIImage imageNamed:@"ZDBtn_more.png" ];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                             initWithTarget:sticker
                                             action:@selector(flipVertical:)];
        [control addGestureRecognizer:singleTap];
        [singleTap release];
        
        return [control autorelease];
    }
    return nil;
}

- (void)hideAll {
    NSArray *poss = [_controlSet allKeys];
    for (NSString *pos in poss) {
        UIView *control = [_controlSet objectForKey:pos];
        [control removeFromSuperview];
    }
}

- (void)showAll {
    NSArray *poss = [_controlSet allKeys];
    for (NSString *pos in poss) {
        UIView *control = [_controlSet objectForKey:pos];
        [self addSubview:control];
    }
}

//instance method
- (void)deleteTap:(UITapGestureRecognizer *)recognizer {
    if (NO == self.preventsDeleting) {
        UIView *close = (UIView *)[recognizer view];
        [close.superview removeFromSuperview];
    }
    
    if([self.delegate respondsToSelector:@selector(stickerViewDidClose:)]) {
        [self.delegate stickerViewDidClose:self];
    }
}

- (void)resizeMoved:(UIPanGestureRecognizer *)recognizer {
    if ([recognizer state]== UIGestureRecognizerStateBegan) {
        self.prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
    } else if ([recognizer state] == UIGestureRecognizerStateChanged) {
        if (self.bounds.size.width < self.minWidth || self.bounds.size.height < self.minHeight) {
            self.bounds = CGRectMake(self.bounds.origin.x,
                                     self.bounds.origin.y,
                                     self.minWidth,
                                     self.minHeight);
            [self layoutControlSet];
            self.prevPoint = [recognizer locationInView:self];
        } else {
            CGPoint point = [recognizer locationInView:self];
            float wChange = (point.x - self.prevPoint.x);
            float hChange = (point.y - self.prevPoint.y);
                        
            if (ABS(wChange) > 20.0f || ABS(hChange) > 20.0f) {
                self.prevPoint = [recognizer locationInView:self];
                return;
            }
            
            if (YES == self.preventsLayoutWhileResizing) {
                if (wChange < 0.0f && hChange < 0.0f) {
                    float change = MIN(wChange, hChange);
                    wChange = change;
                    hChange = change;
                }
                if (wChange < 0.0f) {
                    hChange = wChange;
                } else if (hChange < 0.0f) {
                    wChange = hChange;
                } else {
                    float change = MAX(wChange, hChange);
                    wChange = change;
                    hChange = change;
                }
            }
            
            self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y,
                                     self.bounds.size.width + (wChange),
                                     self.bounds.size.height + (hChange));
            [self layoutControlSet];
            self.prevPoint = [recognizer locationInView:self];
        }
        
        /* Rotation */
        float ang = atan2([recognizer locationInView:self.superview].y - self.center.y,
                          [recognizer locationInView:self.superview].x - self.center.x);
        float angleDiff = self.deltaAngle - ang;
        if (NO == self.preventsResizing) {
            self.transform = CGAffineTransformMakeRotation(-angleDiff);
        }
        
        [self setNeedsDisplay];
    } else if ([recognizer state] == UIGestureRecognizerStateEnded) {
        self.prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
    }
}

- (void)moreTap:(UITapGestureRecognizer *)recognizer {
    if([self.delegate respondsToSelector:@selector(stickerViewDidShowMore:)]) {
        [self.delegate stickerViewDidShowMore:self];
    }
}

- (void)flipHorizon:(UITapGestureRecognizer *)recognizer {
    self.horizonFlipped = !self.horizonFlipped;
    //x y
    //CGAffineTransformIdentity
    self.contentView.transform = CGAffineTransformMakeScale(self.horizonFlipped? -1: 1, self.verficalFlipped? -1: 1);
}

- (void)flipVertical:(UITapGestureRecognizer *)recognizer {
    self.verficalFlipped = !self.verficalFlipped;
    self.contentView.transform = CGAffineTransformMakeScale(self.horizonFlipped? -1: 1, self.verficalFlipped? -1: 1);
}

@end



@interface ZDStickerView () {

}

@property (nonatomic) CGAffineTransform startTransform;
@property (nonatomic) CGPoint touchStart;

@end


@implementation ZDStickerView

@synthesize contentView, touchStart;
@synthesize startTransform; //rotation
@synthesize preventsPositionOutsideSuperview;
@synthesize preventsResizing;
@synthesize preventsDeleting;

- (void)dealloc {
    [_controlSet release];
    
    [super dealloc];
}

- (void)doubleTap {
    if([_delegate respondsToSelector:@selector(stickerViewDidDoubleTap:)]) {
        [_delegate stickerViewDidDoubleTap:self];
    }
}

+ (CGRect)initFrame:(CGRect)currentFrame {
    float minH = currentFrame.size.height, minW = currentFrame.size.width;
    if (kSPUserResizableViewDefaultMinWidth > currentFrame.size.width*0.5
        || kSPUserResizableViewDefaultMinWidth > currentFrame.size.height*0.5) {
        if ( currentFrame.size.height <  currentFrame.size.width) {
            minH = kSPUserResizableViewDefaultMinWidth;
            minW = currentFrame.size.width * (kSPUserResizableViewDefaultMinWidth/currentFrame.size.height);
        } else {
            minW = kSPUserResizableViewDefaultMinWidth;
            if (currentFrame.size.width > 0 && currentFrame.size.height > 0) {
                minH = currentFrame.size.height * (kSPUserResizableViewDefaultMinWidth/currentFrame.size.width);
            } else {
                minW = kSPUserResizableViewDefaultMinWidth;
            }
        }
    } else {
        minW = currentFrame.size.width*0.5;
        minH = currentFrame.size.height*0.5;
    }
    return CGRectMake(0, 0, minW, minH);
}

- (void)setupDefaultAttributes {
    _frame = [[UIView alloc] initWithFrame:FRAME_FRAME];
    _frame.backgroundColor = [UIColor clearColor];
    [self addSubview:_frame];
    [_frame release];
    
    if (kSPUserResizableViewDefaultMinWidth > self.bounds.size.width*0.5
        || kSPUserResizableViewDefaultMinWidth > self.bounds.size.height*0.5) {
        if ( self.bounds.size.height <  self.bounds.size.width) {
            self.minHeight = kSPUserResizableViewDefaultMinWidth;
            self.minWidth = self.bounds.size.width * (kSPUserResizableViewDefaultMinWidth/self.bounds.size.height);
        } else {
            self.minWidth = kSPUserResizableViewDefaultMinWidth;
            self.minHeight = self.bounds.size.height * (kSPUserResizableViewDefaultMinWidth/self.bounds.size.width);
        }
    } else {
        self.minWidth = self.bounds.size.width*0.5;
        self.minHeight = self.bounds.size.height*0.5;
    }
    
    self.preventsPositionOutsideSuperview = YES;
    self.preventsLayoutWhileResizing = YES;
    self.preventsResizing = NO;
    self.preventsDeleting = NO;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(doubleTap)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.cancelsTouchesInView = NO;
    [self addGestureRecognizer:doubleTap];
    [doubleTap release];
    
    /*
     control part
     */
    UIView *delCtr = [ZDStickerView getControl:DELETE forSticker:self];
    [self addControl:delCtr atPos:POS_UP_RIGHT];
    [self addSubview:delCtr];
    
    UIView *resizingCtr = [ZDStickerView getControl:RESIZE forSticker:self];
    [self addControl:resizingCtr atPos:POS_DOWN_RIGHT];
    
    UIView *flipVCtr = [ZDStickerView getControl:VERTICAL_FLIP forSticker:self];
    [self addControl:flipVCtr atPos:POS_UP_LEFT];
    
    UIView *flipHCtr = [ZDStickerView getControl:HORIZON_FLIP forSticker:self];
    [self addControl:flipHCtr atPos:POS_DOWN_LEFT];

//    UIView *moreCtr = [ZDStickerView getControl:MORE forSticker:self];
//    [ZDStickerView addControl:moreCtr atPos:POS_UP_RIGHT toSticker:self];
//    [self addSubview:moreCtr];
    
    self.deltaAngle = atan2(self.frame.origin.y+self.frame.size.height - self.center.y,
                       self.frame.origin.x+self.frame.size.width - self.center.x);
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupDefaultAttributes];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupDefaultAttributes];
    }
    return self;
}

- (void)setContentView:(UIView *)newContentView {
    [contentView removeFromSuperview];
    contentView = newContentView;
    contentView.frame = CONTENT_FRAME;
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:contentView];
    [self bringControlToFront];
}

- (void)setFrame:(CGRect)newFrame {
    [super setFrame:newFrame];

    contentView.frame = CONTENT_FRAME;
    [self layoutControlSet];
}

- (void)showFrame:(bool)show {
    if (show) {
        _frame.layer.borderColor = [UIColor orangeColor].CGColor;
        _frame.layer.borderWidth = 1;
    } else {
        _frame.layer.borderColor = [UIColor clearColor].CGColor;
        _frame.layer.borderWidth = 0;
    }
}


#pragma mark touch related
- (void)translateUsingTouchLocation:(CGPoint)touchPoint {
    CGPoint newCenter = CGPointMake(self.center.x + touchPoint.x - touchStart.x,
                                    self.center.y + touchPoint.y - touchStart.y);
    if (self.preventsPositionOutsideSuperview) {
        // Ensure the translation won't cause the view to move offscreen.
//        CGFloat midPointX = CGRectGetMidX(self.bounds);
//        if (newCenter.x > self.superview.bounds.size.width - midPointX) {
//            newCenter.x = self.superview.bounds.size.width - midPointX;
//        }
//        if (newCenter.x < midPointX) {
//            newCenter.x = midPointX;
//        }
//        CGFloat midPointY = CGRectGetMidY(self.bounds);
//        if (newCenter.y > self.superview.bounds.size.height - midPointY) {
//            newCenter.y = self.superview.bounds.size.height - midPointY;
//        }
//        if (newCenter.y < midPointY) {
//            newCenter.y = midPointY;
//        }
    }
    self.center = newCenter;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    touchStart = [touch locationInView:self.superview];
    if([_delegate respondsToSelector:@selector(stickerViewDidBeginEditing:)]) {
        [_delegate stickerViewDidBeginEditing:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Notify the delegate we've ended our editing session.
    if([_delegate respondsToSelector:@selector(stickerViewDidEndEditing:)]) {
        [_delegate stickerViewDidEndEditing:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // Notify the delegate we've ended our editing session.
    if([_delegate respondsToSelector:@selector(stickerViewDidCancelEditing:)]) {
        [_delegate stickerViewDidCancelEditing:self];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touch = [[touches anyObject] locationInView:self.superview];
    [self translateUsingTouchLocation:touch];
    touchStart = touch;
}


#pragma mark btn hide
- (void)hideEditingHandles {
    [self hideAll];
}

- (void)showEditingHandles {
    [self showAll];
}


@end
