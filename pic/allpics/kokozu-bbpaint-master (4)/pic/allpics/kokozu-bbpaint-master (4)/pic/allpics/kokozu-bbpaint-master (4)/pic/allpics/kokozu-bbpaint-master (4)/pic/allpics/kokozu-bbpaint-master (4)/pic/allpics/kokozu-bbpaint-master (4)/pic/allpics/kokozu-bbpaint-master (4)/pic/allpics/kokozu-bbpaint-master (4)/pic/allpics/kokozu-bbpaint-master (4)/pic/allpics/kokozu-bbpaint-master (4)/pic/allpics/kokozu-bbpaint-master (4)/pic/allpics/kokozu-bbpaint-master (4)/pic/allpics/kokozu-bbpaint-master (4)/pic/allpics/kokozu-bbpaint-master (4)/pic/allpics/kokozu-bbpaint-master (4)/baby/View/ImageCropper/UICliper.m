//
//  UICliper.m
//
//  Created by Xu Yang on 12-8-14.
//  Copyright (c) 2012年 KoKoZu. All rights reserved.
//

#import "UICliper.h"


#define kBounceMargin 20
#define kMinWidth 100
#define kThreshold 5.0
#define kInfinity 10000


@implementation UICliper


@synthesize responder;
@synthesize clipperFrame;
@synthesize frameColor;


- (void)dealloc {
    [overlayColor release];
    self.frameColor = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
         frameColor:(UIColor *)fColor
          responder:(UIView *)respond
         edgeInsets:(UIEdgeInsets)insets {
    
    self = [super initWithFrame:frame];

    if (self) {
        self.responder = respond;
        
        self.backgroundColor = [UIColor clearColor];
        self.multipleTouchEnabled = NO;
        overlayColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.6];
        touchPoint = CGPointZero;
        self.frameColor = fColor;
        
        clipperFlags.draggingTop = kInfinity;
        clipperFlags.draggingRight = kInfinity;
        clipperFlags.draggingBottom = kInfinity;
        clipperFlags.draggingLeft = kInfinity;
        
        availableFrame = frame;
        availableFrame.origin.x += insets.left;
        availableFrame.size.width -= insets.left;
        availableFrame.origin.y += insets.top;
        availableFrame.size.height -= insets.top;
        availableFrame.size.width -= insets.right;
        availableFrame.size.height -= insets.bottom;
        
        if (insets.top || insets.right || insets.bottom || insets.left) {
            clipperFrame = availableFrame;
        } else {
            clipperFrame = CGRectMake(availableFrame.origin.x + 10,
                                      availableFrame.origin.y + 10,
                                      availableFrame.size.width - 20,
                                      availableFrame.size.height -20);
        }
        
    }

    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //绘制剪裁区域外半透明效果
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, overlayColor.CGColor);
    //top
    CGContextFillRect(context, CGRectMake(0, 0, rect.size.width, clipperFrame.origin.y));
    //left
    CGContextFillRect(context, CGRectMake(0, clipperFrame.origin.y, clipperFrame.origin.x, clipperFrame.size.height));
    //right
    CGContextFillRect(context, CGRectMake(clipperFrame.origin.x + clipperFrame.size.width,
                                          clipperFrame.origin.y,
                                          rect.size.width - clipperFrame.origin.x - clipperFrame.size.width,
                                          clipperFrame.size.height));
    //bottom
    CGContextFillRect(context, CGRectMake(0,
                                          clipperFrame.origin.y + clipperFrame.size.height,
                                          rect.size.width,
                                          rect.size.height - clipperFrame.origin.y - clipperFrame.size.height));
    CGContextRestoreGState(context);

    //绘制剪裁区域的格子
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, self.frameColor.CGColor);
    CGContextSetLineWidth(context, 2.0);
    CGContextAddRect(context, clipperFrame);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);

    //绘制分割线
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, self.frameColor.CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextAddRect(context, CGRectMake(clipperFrame.origin.x + clipperFrame.size.width*1.0/3,
                                         clipperFrame.origin.y,
                                         clipperFrame.size.width/3.0,
                                         clipperFrame.size.height));
    CGContextAddRect(context, CGRectMake(clipperFrame.origin.x,
                                         clipperFrame.origin.y + clipperFrame.size.height*1.0/3,
                                         clipperFrame.size.width,
                                         clipperFrame.size.height/3.0));
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    //绘制格子四角
    int indicatorWith = 16;

    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, self.frameColor.CGColor);
    CGContextSetLineWidth(context, 0.0);

    CGContextFillRect(context, CGRectMake(clipperFrame.origin.x, clipperFrame.origin.y, indicatorWith, 4));
    CGContextFillRect(context, CGRectMake(CGRectGetMaxX(clipperFrame) - indicatorWith, clipperFrame.origin.y, indicatorWith, 4));
    CGContextFillRect(context, CGRectMake(clipperFrame.origin.x, clipperFrame.origin.y, 4, indicatorWith));
    CGContextFillRect(context, CGRectMake(CGRectGetMaxX(clipperFrame) - 4, clipperFrame.origin.y, 4, indicatorWith));
    
    CGContextFillRect(context, CGRectMake(clipperFrame.origin.x,
                                          CGRectGetMaxY(clipperFrame) - indicatorWith,
                                          4,
                                          indicatorWith));
    CGContextFillRect(context, CGRectMake(CGRectGetMaxX(clipperFrame) - 4,
                                          CGRectGetMaxY(clipperFrame) - indicatorWith,
                                          4,
                                          indicatorWith));
    CGContextFillRect(context, CGRectMake(clipperFrame.origin.x,
                                          CGRectGetMaxY(clipperFrame) - 4,
                                          indicatorWith,
                                          4));
    CGContextFillRect(context, CGRectMake(CGRectGetMaxX(clipperFrame) - indicatorWith,
                                          CGRectGetMaxY(clipperFrame) - 4,
                                          indicatorWith,
                                          4));
    
    CGContextRestoreGState(context);
    
}

- (void)resetBounds{
    
    if (!CGRectEqualToRect(availableFrame, self.frame)) {
        clipperFrame = availableFrame;
    } else {
        clipperFrame = CGRectMake(availableFrame.origin.x + 10,
                                  availableFrame.origin.y + 10,
                                  availableFrame.size.width - 20,
                                  availableFrame.size.height -20);
    }

    [self setNeedsDisplay];
}

- (CGPoint)pointOnFrame:(CGPoint)tPoint {
    float leftDelta = tPoint.x-clipperFrame.origin.x;
    float rightDelta = tPoint.x-clipperFrame.origin.x-clipperFrame.size.width;
    float topDelta = tPoint.y-clipperFrame.origin.y;
    float bottomDelta = tPoint.y-clipperFrame.origin.y-clipperFrame.size.height;
    
    float minVerticalDelta = .0f, minHorizonDelta = .0f;    
    
    if ( fabsf(leftDelta) <= fabsf(rightDelta) ) {
        clipperFlags.draggingLeft = 0;
        minVerticalDelta = fabsf(leftDelta);
    } else {
        clipperFlags.draggingRight = 0;
        minVerticalDelta = fabsf(rightDelta);
    }
    if ( fabsf(topDelta) <= fabsf(bottomDelta) ) {
        clipperFlags.draggingTop = 0;
        minHorizonDelta = fabsf(topDelta);
    } else {
        clipperFlags.draggingBottom = 0;
        minHorizonDelta = fabsf(bottomDelta);
    }
        
    if (minVerticalDelta <= minHorizonDelta) {
        clipperFlags.draggingTop += kThreshold;
        clipperFlags.draggingBottom += kThreshold;

        if (tPoint.y <= CGRectGetMinY(clipperFrame)) {
            return CGPointMake(
                               clipperFlags.draggingLeft? CGRectGetMinX(clipperFrame): CGRectGetMaxX(clipperFrame),
                               CGRectGetMinY(clipperFrame)
                               );
        } else if (tPoint.y >= CGRectGetMaxY(clipperFrame)) {
            return CGPointMake(
                               clipperFlags.draggingLeft? CGRectGetMinX(clipperFrame): CGRectGetMaxX(clipperFrame),
                               CGRectGetMaxY(clipperFrame)
                               );
        } else {
            return CGPointMake(
                               clipperFlags.draggingLeft? CGRectGetMinX(clipperFrame): CGRectGetMaxX(clipperFrame),
                               tPoint.y
                               );
        }
    } else {
        clipperFlags.draggingLeft += kThreshold;
        clipperFlags.draggingRight += kThreshold;
        
        if (tPoint.x <= CGRectGetMinX(clipperFrame)) {
            return CGPointMake(
                               CGRectGetMinX(clipperFrame),
                               clipperFlags.draggingTop? CGRectGetMinY(clipperFrame): CGRectGetMaxY(clipperFrame)
                               );
        } else if (tPoint.x >= CGRectGetMaxX(clipperFrame)) {
            return CGPointMake(
                               CGRectGetMaxX(clipperFrame),
                               clipperFlags.draggingTop? CGRectGetMinY(clipperFrame): CGRectGetMaxY(clipperFrame)
                               );
        } else {
            return CGPointMake(
                               tPoint.x,
                               clipperFlags.draggingTop? CGRectGetMinY(clipperFrame): CGRectGetMaxY(clipperFrame)
                               );
        }
    }
}



#pragma mark touch related
- (id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    NSSet *allTouches = [event allTouches];
//    DLog(@"%d",[allTouches count]);
    
    if ([allTouches count] == 0) {
        float x = point.x, y = point.y;
        if( fabs( x-clipperFrame.origin.x ) > kBounceMargin
           && fabs( x-clipperFrame.origin.x-clipperFrame.size.width ) > kBounceMargin
           && fabs( y-clipperFrame.origin.y ) > kBounceMargin
           && fabs( y-clipperFrame.origin.y-clipperFrame.size.height) > kBounceMargin ){ //圈内&圈外
            return responder;
        } else {
            return self;
        }
    }
    return responder;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    touchPoint = [[touches anyObject] locationInView:self];
    framePoint = [self pointOnFrame:touchPoint];
    
//    DLog(@"touch point:%@, frame point:%@, frame:%@",
//         NSStringFromCGPoint(touchPoint),
//         NSStringFromCGPoint(framePoint),
//         NSStringFromCGRect(clipperFrame));
    
//    DLog(@"left:%d, right:%d, top:%d, bottom:%d",
//         clipperFlags.draggingLeft,
//         clipperFlags.draggingRight,
//         clipperFlags.draggingTop,
//         clipperFlags.draggingBottom);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    CGPoint point = [[touches anyObject] locationInView:self];

    float deltaX = point.x - touchPoint.x, deltaY = point.y - touchPoint.y;
//    DLog(@"x:%f y:%f", deltaX, deltaY);
    
    framePoint.x += deltaX;
    framePoint.y += deltaY;
    
    CGPoint clipperOrigin = clipperFrame.origin;
    CGPoint clipperEnd = CGPointMake(CGRectGetMaxX(clipperFrame), CGRectGetMaxY(clipperFrame));
    
//   DLog(@"frame point:%@, frame:%@", NSStringFromCGPoint(framePoint), NSStringFromCGRect(clipperFrame));
    

    //move vertical side
    if ( clipperFlags.draggingLeft < fabsf(deltaX) ) {
        clipperOrigin.x += deltaX;
        if (clipperOrigin.x > clipperEnd.x - kMinWidth)
            clipperOrigin.x = clipperEnd.x - kMinWidth;
        if (clipperOrigin.x < CGRectGetMinX(availableFrame)) {
            clipperOrigin.x = CGRectGetMinX(availableFrame);
        }
    }
    if ( clipperFlags.draggingRight < fabsf(deltaX) ) {
        clipperEnd.x += deltaX;
        if (clipperEnd.x < clipperOrigin.x + kMinWidth)
            clipperEnd.x = clipperOrigin.x + kMinWidth;
        if (clipperEnd.x > CGRectGetMaxX(availableFrame)) {
            clipperEnd.x = CGRectGetMaxX(availableFrame);
        }
    }
    
    //move horizon side
    if ( clipperFlags.draggingTop < fabsf(deltaY) ) {
        clipperOrigin.y += deltaY;
        if (clipperOrigin.y > CGRectGetMaxY(clipperFrame) - kMinWidth)
            clipperOrigin.y = CGRectGetMaxY(clipperFrame) - kMinWidth;
        if (clipperOrigin.y < CGRectGetMinY(availableFrame)) {
            clipperOrigin.y = CGRectGetMinY(availableFrame);
        }
    }
    if ( clipperFlags.draggingBottom < fabsf(deltaY) ) {
        clipperEnd.y += deltaY;
        if (clipperEnd.y < clipperOrigin.y + kMinWidth)
            clipperEnd.y = clipperOrigin.y + kMinWidth;
        if (clipperEnd.y > CGRectGetMaxY(availableFrame)) {
            clipperEnd.y = CGRectGetMaxY(availableFrame);
        }
    }
        
    clipperFrame = CGRectMake(clipperOrigin.x,
                              clipperOrigin.y,
                              clipperEnd.x - clipperOrigin.x,
                              clipperEnd.y - clipperOrigin.y);
    [self setNeedsDisplay];
    
    touchPoint = point;
    framePoint = [self pointOnFrame:touchPoint];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    touchPoint = CGPointZero;
    framePoint = CGPointZero;
    
    clipperFlags.draggingTop = kInfinity;
    clipperFlags.draggingRight = kInfinity;
    clipperFlags.draggingBottom = kInfinity;
    clipperFlags.draggingLeft = kInfinity;
    
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:nil withEvent:nil];
}



@end
