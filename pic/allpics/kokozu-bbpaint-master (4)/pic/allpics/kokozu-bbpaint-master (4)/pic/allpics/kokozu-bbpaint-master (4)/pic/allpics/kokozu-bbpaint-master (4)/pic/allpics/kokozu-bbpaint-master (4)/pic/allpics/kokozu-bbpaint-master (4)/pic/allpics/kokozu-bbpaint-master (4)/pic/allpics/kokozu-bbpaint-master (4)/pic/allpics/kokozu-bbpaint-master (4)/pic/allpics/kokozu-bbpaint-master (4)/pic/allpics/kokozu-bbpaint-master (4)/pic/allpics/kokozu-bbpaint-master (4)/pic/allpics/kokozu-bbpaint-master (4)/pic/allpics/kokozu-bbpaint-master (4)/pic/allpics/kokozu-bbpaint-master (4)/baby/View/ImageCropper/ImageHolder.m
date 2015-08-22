//
//  ImageHolder.m
//  KoMovie
//
//  Created by alfaromeo on 12-6-18.
//  Copyright (c) 2012年 kokozu. All rights reserved.
//



#import "ImageHolder.h"


#define kZoomScale 1.2

#define kDebugImageHolder 0

@implementation ImageHolder


@synthesize holderDelegate = _holderDelegate;

- (void)dealloc {
	
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.alwaysBounceHorizontal = YES;
        self.alwaysBounceVertical = YES;
        self.maximumZoomScale = 2.0;
        self.minimumZoomScale = 1.0;

		imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.userInteractionEnabled = YES;
        [self addSubview:imageView];
        self.contentSize = imageView.frame.size;
        [imageView release];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        doubleTap.cancelsTouchesInView = NO;
        [self addGestureRecognizer:doubleTap];
        [doubleTap release];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        tap.cancelsTouchesInView = NO;
        [tap requireGestureRecognizerToFail:doubleTap];
        [self addGestureRecognizer:tap];
        [tap release];
	}
	
	return self;
}

- (void)layoutSubviews  {
    [super layoutSubviews];

    CGSize boundsSize = self.bounds.size;
    boundsSize.width = boundsSize.width - self.contentInset.left - self.contentInset.right;
    boundsSize.height = boundsSize.height - self.contentInset.top - self.contentInset.bottom;
    
    CGRect frameToCenter = imageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
#if kDebugImageHolder
    DLog(@"image view frame: %@", NSStringFromCGRect(frameToCenter));
#endif
    
    imageView.frame = frameToCenter;
}



#pragma mark utilities
- (void)setMaxMinZoomScalesForCurrentBounds {
    CGSize boundsSize = self.bounds.size;
    boundsSize.width = boundsSize.width - self.contentInset.left - self.contentInset.right;
    boundsSize.height = boundsSize.height - self.contentInset.top - self.contentInset.bottom;
    
    CGSize imageSize = imageView.bounds.size;
    
    CGFloat minScale = 1, maxScale = 1;
    
    CGFloat xScale = boundsSize.width / imageSize.width, yScale = boundsSize.height / imageSize.height;
    if (xScale > 1 && yScale > 1) {
        maxScale = MAX(xScale, yScale);
    } else {
        minScale = MIN(xScale, yScale);
    }
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
}

- (void)setImage:(UIImage *)image {
    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;
    self.contentOffset = CGPointZero;
    
    // make a new UIImageView for the new image
    imageView.bounds = CGRectMake(0, 0, image.size.width, image.size.height);

    imageView.image = image;
    self.contentSize = image.size;
    
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;
}

- (UIImage *)image {
    return imageView.image;
}

- (UIImage *)getImageWithRect:(CGRect)desiredRect {

#if kDebugImageHolder
    DLog(@"desired rect:%@, content size:%@, content offset:%@, image view frame:%@",
         NSStringFromCGRect(desiredRect),
         NSStringFromCGSize(self.contentSize),
         NSStringFromCGPoint(self.contentOffset),
         NSStringFromCGRect(imageView.frame));
#endif

    float scale = 1.0 / self.zoomScale;
    
    /*
     croprect的坐标系是以scrollview的坐标系为原点
     imageview的坐标系是以scrollview的contentview的坐标系为原点
     scrollview的content和本身的坐标相差一个offset，和contentinset无关，contentinset的影响就是增加contentoffset的范围
     */
    
    //将imageview的frame换算到scrollview的坐标系
    CGRect imageRealRect = imageView.frame;
    imageRealRect.origin.x -= self.contentOffset.x;
    imageRealRect.origin.y -= self.contentOffset.y;
    
    //算出imageview和croprect的交集
    CGRect realCropRect;
    realCropRect = CGRectIntersection(desiredRect, imageRealRect);
    
    //将相交的部分换算到imageview的坐标系内，乘以scale
    realCropRect.origin.x = (desiredRect.origin.x - imageRealRect.origin.x) * scale;
    realCropRect.origin.y = (desiredRect.origin.y - imageRealRect.origin.y) * scale;
    realCropRect.size.width = desiredRect.size.width * scale;
    realCropRect.size.height = desiredRect.size.height * scale;
    
    UIImage *cropped = [self subImage:imageView.image withRect:realCropRect];
    
#if kDebugImageHolder
    DLog(@"crop rect:%@, cropped image:%@, size:%@",
         NSStringFromCGRect(realCropRect), cropped, NSStringFromCGSize(cropped.size));
    
    [self setImage:cropped];
#endif
  
    return cropped;
    
}

- (UIImage*)subImage:(UIImage*)image withRect:(CGRect)rect {
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, image.size.width, image.size.height);

    //clip to the bounds of the image context
    //not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, drawRect.size.width, drawRect.size.height));
    
    //add background color
    [[UIColor whiteColor] set];
#if kDebugImageHolder
    [[UIColor redColor] set];
#endif
    CGContextFillRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));

    //draw image
    [self.image drawInRect:drawRect];
    
    //grab image
    UIImage *subImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [self rotateImage:subImage trans:self.transform];
}

- (UIImage *)rotateImage:(UIImage *)image trans:(CGAffineTransform)trans {
    // Calculate Destination Size
    //CGAffineTransform t = trans;//CGAffineTransformMakeRotation(rotation);
    float angle = atan2(trans.b, trans.a);
    CGRect sizeRect = (CGRect) {.size = image.size};
    CGRect destRect = CGRectApplyAffineTransform(sizeRect, trans);
    CGSize destinationSize = destRect.size;
    
    // Draw image
    UIGraphicsBeginImageContext(destinationSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, destinationSize.width / 2.0f, destinationSize.height / 2.0f);
    CGContextRotateCTM(context, angle);
    [image drawInRect:CGRectMake(-image.size.width / 2.0f, -image.size.height / 2.0f, image.size.width, image.size.height)];
    
    // Save image
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = self.frame.size.height / scale;
    zoomRect.size.width  = self.frame.size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

- (void)singleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (_holderDelegate && [_holderDelegate respondsToSelector:@selector(imageHolder:singleTapAtPoint:)]) {
        [_holderDelegate imageHolder:self singleTapAtPoint:[gestureRecognizer locationInView:imageView]];
    }
}

- (void)doubleTap:(UIGestureRecognizer *)gestureRecognizer {
    float newScale = self.zoomScale * kZoomScale;
    
    if (self.zoomScale == self.maximumZoomScale) {
        newScale = self.minimumZoomScale;
    }
    if (newScale > self.maximumZoomScale) {
        newScale = self.maximumZoomScale;
    }
    if (newScale != self.zoomScale) {
        CGRect zoomRect = [self zoomRectForScale:newScale
                                      withCenter:[gestureRecognizer locationInView:imageView]];
        [self zoomToRect:zoomRect animated:YES];
    }
}



#pragma mark uiscrollview delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return imageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_holderDelegate && [_holderDelegate respondsToSelector:@selector(imageHolderDidScroll:)]) {
        [_holderDelegate imageHolderDidScroll:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ( !decelerate) {
        if (_holderDelegate && [_holderDelegate respondsToSelector:@selector(imageHolderDidEndScroll:)]) {
            [_holderDelegate imageHolderDidEndScroll:self];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_holderDelegate && [_holderDelegate respondsToSelector:@selector(imageHolderDidEndScroll:)]) {
        [_holderDelegate imageHolderDidEndScroll:self];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (_holderDelegate && [_holderDelegate respondsToSelector:@selector(imageHolderDidEndScroll:)]) {
        [_holderDelegate imageHolderDidEndScroll:self];
    }
}


@end